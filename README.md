# 🧪 NixOS Configuration Setup

This repository contains a complete `configuration.nix` setup for my personal NixOS system, including:

- Preconfigured `configuration.nix`
- Hardware-specific modules (e.g., for NVIDIA graphics)
- File system mount instructions (including additional HDDs)

---

## ⚙️ Steps to Use This Configuration

### ✅ 1. Install NixOS Fresh

When installing NixOS:

- Choose **"Erase disk"** option for the main NVMe drive.
- This will ensure `configuration.nix` and `hardware-configuration.nix` are generated cleanly with NVMe boot settings.

---

### 🧰 2. Install Git and Clone the Repo

After installation:

```sh
nix-shell -p git
git clone https://github.com/prajjwalkumar17/nixos.git
```

---

### 🛠️ 3. Replace System Config

Do the following in `/etc/nixos`:

```sh
cd /etc/nixos
```

- **Replace** the existing `configuration.nix` with the one from the repo:

```sh
cp ~/nixos/configuration.nix .
```

- **Copy the `modules/` folder** (contains things like NVIDIA setup):

```sh
cp -r ~/nixos/modules .
```

---

## 🧩 4. Set Up Additional HDD Partitions

### 🔍 Identify Drives

Run:

```sh
lsblk -f
```

Look for non-NVMe entries (e.g., `/dev/sda1`) and note:

- UUID
- Filesystem (e.g., ext4)
- Mount point (if any)

Example output:

```
NAME   FSTYPE LABEL UUID                                 MOUNTPOINT
sda
├─sda1 ext4         a1b2c3d4-e5f6-7890-abcd-1234567890ab /mnt/data
└─sda2 swap         1234abcd-56ef-7890-1234-abcdefabcdef [SWAP]
```

---

### ✍️ Update `hardware-configuration.nix`

Add entries like:

```nix
fileSystems."/mnt/data" = {
  device = "/dev/disk/by-uuid/a1b2c3d4-e5f6-7890-abcd-1234567890ab";
  fsType = "ext4";
};

swapDevices = [
  { device = "/dev/disk/by-uuid/1234abcd-56ef-7890-1234-abcdefabcdef"; }
];
```

💡 You can change the mount point to `/home/yourname/hdd`, `/data`, etc.

---

### 🔁 5. Rebuild Your System

```sh
sudo nixos-rebuild switch
```

---

## 📁 Project Structure

```
nixos/
├── configuration.nix       # Main config file to replace /etc/nixos/configuration.nix
└── modules/                # Optional modules (e.g., NVIDIA-specific setup)
```

---

## 🪪 License

MIT — Feel free to fork and reuse.
