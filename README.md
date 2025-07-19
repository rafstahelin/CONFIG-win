# CONFIG-win - Windows Configuration Scripts

Windows-specific scripts and configurations for ComfyUI and other tools.

Repository: https://github.com/rafstahelin/CONFIG-win

## ComfyUI Scripts

### backup_python_embedded.ps1
Creates timestamped backups of ComfyUI's python_embeded folder before installing custom nodes.

Usage:
```powershell
.\scripts\backup_python_embedded.ps1
# Or with custom path:
.\scripts\backup_python_embedded.ps1 -ComfyUIPath "D:\MyComfyUI"
```

### test_distributed_compatibility.ps1
Complete test script to verify if ComfyUI-Distributed really conflicts with Nunchaku.

Usage:
```powershell
# Run from CONFIG-win directory
.\scripts\test_distributed_compatibility.ps1

# Or specify paths
.\scripts\test_distributed_compatibility.ps1 -ComfyUIPath "E:\ComfyUI_windows_portable" -TestPath "E:\ComfyUI_test"
```

### environment_snapshot.ps1
Captures and compares Windows environment variables to detect changes during installations.

Usage:
```powershell
# Take a snapshot
.\scripts\environment_snapshot.ps1

# Take snapshot and compare with previous
.\scripts\environment_snapshot.ps1 -Compare -CompareWith "env_snapshot_2025-07-19_10-30-00.json"
```

## Quick Testing Strategy

For testing ComfyUI-Distributed compatibility:

1. **Backup current working state**:
   ```powershell
   cd E:\ComfyUI_windows_portable
   E:\dev\CONFIG-win\scripts\backup_python_embedded.ps1
   ```

2. **Run automated test**:
   ```powershell
   E:\dev\CONFIG-win\scripts\test_distributed_compatibility.ps1
   ```

3. **Follow the prompts** to install Distributed via Manager and test

## Environment Variables

The scripts respect the following environment variables:
- `COMFYUI_PATH`: Path to ComfyUI installation (defaults to E:\ComfyUI_windows_portable)

## Related Documentation

- ComfyUI distributed conflict: `/workspace/memory/MEM/workspace/ComfyUI/docs/DISTRIBUTED_CONFLICT.md`
- ComfyUI fixes: `/workspace/memory/MEM/workspace/ComfyUI/docs/FIXES.md`
- Windows roadmap: `/workspace/memory/MEM/workspace/ComfyUI/ROADMAP_WINDOWS.md`
