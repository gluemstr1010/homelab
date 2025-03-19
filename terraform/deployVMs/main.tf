terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.1-rc6"
    }

  }
}

provider "proxmox" {
  pm_api_url = "https://172.16.0.2:8006/api2/json"
  # pm_user = "tfuser@pve"
  # pm_password = "e5aQetDu1nwjNUkO"
  pm_api_token_id = "tfuser@pve!q6jPC6pbWjYx1J8Lcwt0xh7AqCAaT0aX"
  pm_api_token_secret = "bbd9020a-8296-4d96-bee1-1149943278e3"
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "vm1" {
  name        = "kubenode1"
  target_node = "proxmox1"
  cores       = 2
  memory      = 8192

  scsihw = "virtio-scsi-pci"

  disks {
    ide {
      ide2 {
        cdrom {
          iso = "local:iso/talos.iso"
        }
      }
    }

    scsi {
      scsi0 {
        disk {
            size        = "100G"           # Size of the additional disk
            storage     = "labstoragessd"     # Replace with your Ceph pool name
            format      = "qcow2"           # Use qcow2 format for better performance
            discard     = false  
        } 
      }
      scsi1 {
        disk {
            size        = "100G"
            storage     = "labstoragecluster"
            format      = "qcow2"
            discard     = false   
        } 
      }
      scsi2 {
        disk {
            size        = "100G"
            storage     = "labstoragecluster"
            format      = "qcow2"
            discard     = false   
        } 
      }
    }
  } 

  network {
    id = 0
    model   = "virtio"
    bridge  = "vmbr0"
    macaddr = "BC:24:11:F0:B9:90"
  }
}

resource "proxmox_vm_qemu" "vm2" {
  name        = "kubenode2"
  target_node = "proxmox2"
  cores       = 1
  memory      = 6144

  scsihw = "virtio-scsi-pci"

  disks {
    ide {
      ide2 {
        cdrom {
          iso = "local:iso/talos.iso"
        }
      }
    }

    scsi {
      scsi0 {
        disk {
          size        = "100G"
          storage     = "labstoragessd"
          format      = "qcow2" 
          discard     = false  
        } 
      }
      scsi1 {
        disk {
            size        = "100G"
            storage     = "labstoragecluster"
            format      = "qcow2"
            discard     = false    
        } 
      }
      scsi2 {
        disk {
            size        = "100G"
            storage     = "labstoragecluster"
            format      = "qcow2"
            discard     = false   
        } 
      }
    }
  } 

  network {
    id = 1
    model  = "virtio"
    bridge = "vmbr2"  
    macaddr = "BC:24:11:14:96:B5"
  }
}

resource "proxmox_vm_qemu" "vm3" {
 name       = "kubenode3"
 target_node = "proxmox3"
 cores      = 2   
 memory     = 8192

 scsihw = "virtio-scsi-pci"

  disks {
    ide {
      ide2 {
        cdrom {
          iso = "local:iso/talos.iso"
        }
      }
    }

    scsi {
        scsi0 {
          disk{
            size        = "100G"
            storage     = "labstoragessd"
            format      = "qcow2"
            discard     = false  
          }   
      }
      scsi1 {
        disk {
            size        = "100G"
            storage     = "labstoragecluster"
            format      = "qcow2"
            discard     = false    
        } 
      }
      scsi2 {
        disk {
            size        = "100G"
            storage     = "labstoragecluster" 
            format      = "qcow2"           
            discard     = false   
        } 
      }
    }
  } 
   
  network {
    id = 2
    model  = "virtio"
    bridge = "vmbr2"  
    macaddr = "BC:24:11:E2:AA:21"
  }

}

