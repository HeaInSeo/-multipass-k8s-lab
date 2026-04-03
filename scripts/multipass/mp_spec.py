#!/usr/bin/env python3
import json
import sys


def bytes_to_mib(value):
    return int(round(int(str(value)) / (1024 * 1024)))


def pick_vm(obj, name):
    info = obj.get("info", {})
    if name in info:
        return info[name]
    return next(iter(info.values()), {})


def get_cpu(vm):
    if "cpu_count" in vm:
        return int(vm["cpu_count"])
    if "resources" in vm and "cpus" in vm["resources"]:
        return int(vm["resources"]["cpus"])
    raise KeyError("cpu_count not found")


def get_mem_mib(vm):
    mem = vm.get("memory")
    if isinstance(mem, dict) and "total" in mem:
        return bytes_to_mib(mem["total"])
    raise KeyError("memory.total not found")


def get_disk_mib(vm):
    disks = vm.get("disks")
    if isinstance(disks, dict):
        totals = []
        for disk in disks.values():
            if isinstance(disk, dict) and "total" in disk:
                totals.append(bytes_to_mib(disk["total"]))
        if totals:
            return max(totals)
    raise KeyError("disks.*.total not found")


def main():
    if len(sys.argv) != 2:
        print("usage: mp_spec.py <vmname>", file=sys.stderr)
        return 2
    vm = pick_vm(json.load(sys.stdin), sys.argv[1])
    if not vm:
        raise RuntimeError("vm not found")
    print(f"{get_cpu(vm)} {get_mem_mib(vm)} {get_disk_mib(vm)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
