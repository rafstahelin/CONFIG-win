# CONFIG.win - Windows Configuration Scripts

Windows-specific scripts and configurations for ComfyUI and other tools.

## ComfyUI Scripts

### backup_python_embedded.ps1
Creates timestamped backups of ComfyUI's python_embeded folder before installing custom nodes.

Usage:
```powershell
.\scripts\backup_python_embedded.ps1
# Or with custom path:
.\scripts\backup_python_embedded.ps1 -ComfyUIPath "D:\MyComfyUI"
```

## Quick Testing Strategy

For testing ComfyUI-Distributed compatibility:

1. **Backup current working state**:
   ```powershell
   cd E:\ComfyUI_windows_portable
   E:\dev\CONFIG.win\scripts\backup_python_embedded.ps1
   ```

2. **Create full portable copy for testing**:
   ```powershell
   # Create a complete copy
   Copy-Item -Path "E:\ComfyUI_windows_portable" -Destination "E:\ComfyUI_test_distributed" -Recurse
   ```

3. **Test Distributed installation**:
   - Open ComfyUI Manager
   - Search for "ComfyUI-Distributed"
   - Install and observe console output
   - Check if Nunchaku still works

## Environment Variables

The scripts respect the following environment variables:
- `COMFYUI_PATH`: Path to ComfyUI installation (defaults to E:\ComfyUI_windows_portable)

## Related Documentation

- ComfyUI distributed conflict: `/workspace/memory/MEM/workspace/ComfyUI/docs/DISTRIBUTED_CONFLICT.md`
- ComfyUI fixes: `/workspace/memory/MEM/workspace/ComfyUI/docs/FIXES.md`
