#!/usr/bin/python3
"""Configure the two accepted home.arpa administrative accounts in KMail.

Secrets are read from protected ignored files and passed only through in-process
D-Bus calls. This script never prints a credential.
"""

import argparse
import configparser
import os
import random
import shutil
import socket
import stat
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path

import dbus


REPO = Path("/home/louis/helix-arpa/helix-mail-core")
CONFIG = Path("/home/louis/.config")
PRIVATE = REPO / "handoff/private/mail-endpoints"
STATE = REPO / "handoff/private/kmail-admin-accounts"
ACCOUNTS = (
    ("admin", "admin@home.arpa", "Admin"),
    ("cluster-admin", "cluster-admin@home.arpa", "Cluster Admin"),
)
MAIL_HOST = "mail.home.arpa"
MAIL_IPV4 = "192.168.100.199"


def fail(message):
    raise RuntimeError(message)


def run(argv, *, input_text=None, check=True):
    return subprocess.run(
        argv,
        input=input_text,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=check,
    )


def protected_file(path):
    st = path.stat()
    if not stat.S_ISREG(st.st_mode) or stat.S_IMODE(st.st_mode) != 0o600:
        fail(f"protected file mode/type mismatch: {path}")


def read_env(path):
    result = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        if "=" in line:
            key, value = line.split("=", 1)
            result[key] = value
    return result


def read_ini(path):
    parser = configparser.ConfigParser(interpolation=None, strict=False)
    parser.optionxform = str
    if path.exists():
        parser.read(path, encoding="utf-8")
    return parser


def kwrite(file_name, group, key, value):
    run([
        "kwriteconfig6", "--file", file_name, "--group", group,
        "--key", key, str(value),
    ])


def wait_service(bus, service, timeout=15):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if bus.name_has_owner(service):
            return
        time.sleep(0.25)
    fail(f"D-Bus service did not appear: {service}")


def wallet_interface(bus):
    obj = bus.get_object("org.kde.kwalletd6", "/modules/kwalletd6")
    iface = dbus.Interface(obj, "org.kde.KWallet")
    wallet = str(iface.localWallet())
    handle = int(iface.open(wallet, 0, "helix-mail-core-kmail-config"))
    if handle < 0:
        fail("KWallet could not be opened")
    return iface, wallet, handle


def write_wallet_password(iface, handle, folder, key, secret):
    if not bool(iface.hasFolder(handle, folder, "helix-mail-core-kmail-config")):
        if not bool(iface.createFolder(handle, folder, "helix-mail-core-kmail-config")):
            fail(f"KWallet folder could not be created: {folder}")
    result = int(iface.writePassword(
        handle, folder, key, secret, "helix-mail-core-kmail-config"
    ))
    if result != 0:
        fail(f"KWallet rejected entry for folder {folder}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true")
    parser.add_argument(
        "--resume-admin-partial",
        action="store_true",
        help="resume only the reviewed partial state left by the first run",
    )
    args = parser.parse_args()
    if not args.apply:
        fail("render-only by default; pass --apply under the reviewed packet")
    if socket.gethostname().split(".")[0] != "ws-matriarch":
        fail("wrong host")

    git = run(["git", "status", "--short"], check=True)
    if git.stdout.strip():
        fail("repository worktree is not clean")

    secrets = {}
    for slug, identity, _display in ACCOUNTS:
        directory = PRIVATE / slug
        if stat.S_IMODE(directory.stat().st_mode) != 0o700:
            fail(f"protected directory mode mismatch: {directory}")
        credential = directory / "credential"
        identity_file = directory / "identity.env"
        protected_file(credential)
        protected_file(identity_file)
        env = read_env(identity_file)
        if env.get("MAIL_IDENTITY") != identity or env.get("MAIL_USERNAME") != identity:
            fail(f"identity mismatch for {slug}")
        if env.get("MAIL_HOST") != MAIL_HOST or env.get("MAIL_IPV4") != MAIL_IPV4:
            fail(f"server mismatch for {slug}")
        secrets[identity] = credential.read_text(encoding="utf-8").strip()
        if not secrets[identity]:
            fail(f"empty protected credential for {slug}")
    if secrets[ACCOUNTS[0][1]] == secrets[ACCOUNTS[1][1]]:
        fail("administrative credentials are not distinct")

    if MAIL_IPV4 not in {item[4][0] for item in socket.getaddrinfo(MAIL_HOST, 993)}:
        fail("mail.home.arpa address mismatch")

    identities_path = CONFIG / "emailidentities"
    transports_path = CONFIG / "mailtransports"
    identity_cfg = read_ini(identities_path)
    transport_cfg = read_ini(transports_path)
    existing_text = "\n".join(
        [identities_path.read_text(errors="replace") if identities_path.exists() else "",
         transports_path.read_text(errors="replace") if transports_path.exists() else ""]
    )
    if args.resume_admin_partial:
        if "cluster-admin@home.arpa" in existing_text:
            fail("cluster-admin partial state is not expected")
        admin_identity_groups = [
            group for group in identity_cfg.sections()
            if identity_cfg[group].get("Email Address") == "admin@home.arpa"
        ]
        admin_transport_groups = [
            group for group in transport_cfg.sections()
            if transport_cfg[group].get("user") == "admin@home.arpa"
        ]
        if len(admin_identity_groups) != 1 or len(admin_transport_groups) != 1:
            fail("reviewed admin partial state is absent or ambiguous")
        admin_identity_group = admin_identity_groups[0]
        admin_transport_group = admin_transport_groups[0]
        admin_uoid = int(identity_cfg[admin_identity_group].get("uoid", "0"))
        admin_transport_id = int(
            transport_cfg[admin_transport_group].get("id", "0")
        )
        expected_identity = {
            "Default Domain": "home.arpa",
            "Email Address": "admin@home.arpa",
            "Identity": "Admin (home.arpa)",
            "Name": "Admin",
            "Transport": str(admin_transport_id),
            "uoid": str(admin_uoid),
        }
        expected_transport = {
            "auth": "true", "authtype": "1", "encryption": "2",
            "host": MAIL_HOST, "id": str(admin_transport_id),
            "identifier": "SMTP", "name": "SMTP (admin@home.arpa)",
            "port": "587", "storepass": "true", "user": "admin@home.arpa",
        }
        if admin_uoid <= 0 or admin_transport_id <= 0:
            fail("reviewed admin identifiers are invalid")
        if any(identity_cfg[admin_identity_group].get(k) != v
               for k, v in expected_identity.items()):
            fail("admin identity differs from the reviewed partial state")
        if any(transport_cfg[admin_transport_group].get(k) != v
               for k, v in expected_transport.items()):
            fail("admin transport differs from the reviewed partial state")
    else:
        for _slug, identity, _display in ACCOUNTS:
            if identity in existing_text:
                fail(f"identity or transport already exists: {identity}")

    bus = dbus.SessionBus()
    manager_obj = bus.get_object("org.freedesktop.Akonadi.Control", "/AgentManager")
    manager = dbus.Interface(manager_obj, "org.freedesktop.Akonadi.AgentManager")
    resumable_admin_resources = []
    for instance in manager.agentInstances():
        name = str(manager.agentInstanceName(instance))
        if not args.resume_admin_partial and any(
            identity in name for _slug, identity, _display in ACCOUNTS
        ):
            fail(f"Akonadi resource already exists: {name}")
        if args.resume_admin_partial and str(instance).startswith("akonadi_imap_resource_"):
            service = f"org.freedesktop.Akonadi.Resource.{instance}"
            wait_service(bus, service)
            obj = bus.get_object(service, "/Settings")
            candidate = dbus.Interface(obj, "org.kde.Akonadi.Imap.Settings")
            if (
                str(candidate.imapServer()) == MAIL_HOST
                and int(candidate.imapPort()) == 993
                and str(candidate.userName()) == "admin@home.arpa"
                and str(candidate.safety()) == "SSL"
                and int(candidate.authentication()) == 1
                and int(candidate.accountIdentity()) == admin_uoid
                and not bool(candidate.useDefaultIdentity())
                and not bool(candidate.sieveSupport())
            ):
                resumable_admin_resources.append(str(instance))
    if args.resume_admin_partial and len(resumable_admin_resources) != 1:
        fail("expected exactly one reviewed partial admin IMAP resource")

    STATE.mkdir(mode=0o700, parents=True, exist_ok=True)
    os.chmod(STATE, 0o700)
    backup = STATE / datetime.now().strftime("rollback-%Y%m%dT%H%M%S")
    backup.mkdir(mode=0o700)
    for path in (identities_path, transports_path):
        if path.exists():
            shutil.copy2(path, backup / path.name)
            os.chmod(backup / path.name, 0o600)

    used_uoids = {
        int(identity_cfg[group].get("uoid", "0"))
        for group in identity_cfg.sections() if group.startswith("Identity #")
    }
    used_transport_ids = {
        int(transport_cfg[group].get("id", "0"))
        for group in transport_cfg.sections() if group.startswith("Transport ")
    }
    rng = random.SystemRandom()
    uoids = [admin_uoid] if args.resume_admin_partial else []
    transport_ids = [admin_transport_id] if args.resume_admin_partial else []
    while len(uoids) < 2:
        candidate = rng.randrange(1, 2**31 - 1)
        if candidate not in used_uoids and candidate not in uoids:
            uoids.append(candidate)
    while len(transport_ids) < 2:
        candidate = rng.randrange(1, 2**31 - 1)
        if candidate not in used_transport_ids and candidate not in transport_ids:
            transport_ids.append(candidate)

    can_close = run([
        "qdbus-qt6", "org.kde.kmail2", "/KMail",
        "org.kde.kmail.kmail.canQueryClose",
    ], check=False)
    if can_close.returncode == 0 and can_close.stdout.strip().lower() != "true":
        fail("KMail reports that it cannot close safely")
    run(["kquitapp6", "kmail"], check=False)
    time.sleep(2)

    next_identity_index = 0
    while f"Identity #{next_identity_index}" in identity_cfg:
        next_identity_index += 1

    wallet, _wallet_name, wallet_handle = wallet_interface(bus)
    created_resources = []
    for offset, (slug, identity, display) in enumerate(ACCOUNTS):
        transport_id = transport_ids[offset]
        uoid = uoids[offset]
        if args.resume_admin_partial and offset == 0:
            identity_group = admin_identity_group
        else:
            identity_group = f"Identity #{next_identity_index}"
            while identity_group in identity_cfg:
                next_identity_index += 1
                identity_group = f"Identity #{next_identity_index}"
        identity_values = {
            "Default Domain": "home.arpa",
            "Disable Fcc": "false",
            "Disable Spam": "false",
            "Email Address": identity,
            "Identity": f"{display} (home.arpa)",
            "Name": display,
            "Override Encryption Defaults": "false",
            "Signature Enabled": "false",
            "Transport": str(transport_id),
            "uoid": str(uoid),
        }
        if not (args.resume_admin_partial and offset == 0):
            for key, value in identity_values.items():
                kwrite("emailidentities", identity_group, key, value)

        transport_group = f"Transport {transport_id}"
        transport_values = {
            "id": transport_id,
            "name": f"SMTP ({identity})",
            "identifier": "SMTP",
            "host": MAIL_HOST,
            "port": 587,
            "user": identity,
            "auth": "true",
            "storepass": "true",
            "encryption": 2,
            "authtype": 1,
            "precommand": "",
            "useProxy": "false",
        }
        if not (args.resume_admin_partial and offset == 0):
            for key, value in transport_values.items():
                kwrite("mailtransports", transport_group, key, value)
            write_wallet_password(
                wallet, wallet_handle, "mailtransports", str(transport_id),
                secrets[identity]
            )

        if args.resume_admin_partial and offset == 0:
            resource_id = resumable_admin_resources[0]
        else:
            resource_id = str(manager.createAgentInstance("akonadi_imap_resource"))
            if not resource_id.startswith("akonadi_imap_resource_"):
                fail("unexpected Akonadi resource identifier")
        created_resources.append(resource_id)
        manager.setAgentInstanceName(resource_id, f"IMAP ({identity})")
        service = f"org.freedesktop.Akonadi.Resource.{resource_id}"
        wait_service(bus, service)
        settings_obj = bus.get_object(service, "/Settings")
        settings = dbus.Interface(settings_obj, "org.kde.Akonadi.Imap.Settings")
        wallet_settings = dbus.Interface(
            settings_obj, "org.kde.Akonadi.Imap.Wallet"
        )
        settings.setImapServer(MAIL_HOST)
        settings.setImapPort(dbus.Int32(993))
        settings.setUserName(identity)
        settings.setSafety("SSL")
        settings.setAuthentication(dbus.Int32(1))
        settings.setSubscriptionEnabled(True)
        settings.setDisconnectedModeEnabled(True)
        settings.setIntervalCheckEnabled(True)
        settings.setIntervalCheckTime(dbus.Int32(5))
        settings.setUseDefaultIdentity(False)
        settings.setAccountIdentity(dbus.Int32(uoid))
        settings.setSieveSupport(False)
        wallet_settings.setPassword(secrets[identity])
        settings.save()
        time.sleep(2)
        manager.restartAgentInstance(resource_id)
        manager.setAgentInstanceOnline(resource_id, True)

    if not transport_cfg.sections():
        kwrite("mailtransports", "General", "default-transport", transport_ids[0])

    os.chmod(identities_path, 0o600)
    os.chmod(transports_path, 0o600)
    subprocess.Popen(
        ["kmail"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        start_new_session=True,
    )
    time.sleep(5)
    for resource_id in created_resources:
        manager.agentInstanceSynchronize(resource_id)

    # Do not disclose generated identifiers as they are operational metadata only.
    print("KMAIL CONFIGURATION APPLIED")
    print(f"rollback directory: {backup}")


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"KMAIL CONFIGURATION FAILED: {exc}", file=sys.stderr)
        raise SystemExit(1)
