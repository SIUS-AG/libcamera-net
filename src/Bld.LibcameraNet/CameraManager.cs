using Bld.LibcameraNet.Interop;
using System.Reflection;
using System.Runtime.InteropServices;
using LibcameraNative = Bld.LibcameraNet.Interop.Libcamera.LibcameraNative;

namespace Bld.LibcameraNet;

public class CameraManager : IDisposable
{
    private bool _disposedValue;
    private readonly IntPtr _nativeCameraManager;

    static CameraManager()
    {
        NativeLibrary.SetDllImportResolver(typeof(CameraManager).Assembly, DllImportResolver);
    }

    public CameraManager()
    {
        _nativeCameraManager = LibcameraNative.CameraManagerCreate();
    }

    private static IntPtr DllImportResolver(string libraryName, Assembly assembly, DllImportSearchPath? searchPath)
    {
        if (libraryName.StartsWith("libcamera"))
        {
            // Try multiple paths to find the library
            var assemblyDir = Path.GetDirectoryName(assembly.Location);
            var possiblePaths = new[]
            {
                Path.Combine(assemblyDir!, Interop.Libcamera.LibcameraConsts.LibName),
                Path.Combine(assemblyDir!, "runtimes", "linux-arm64", "native", Interop.Libcamera.LibcameraConsts.LibName),
                Interop.Libcamera.LibcameraConsts.LibName // Try system path
            };

            foreach (var path in possiblePaths)
            {
                if (File.Exists(path))
                {
                    return NativeLibrary.Load(path);
                }
            }
        }

        // Otherwise, fallback to default import resolver.
        return IntPtr.Zero;
    }

    public nint Start()
    {
        return LibcameraNative.CameraManagerStart(_nativeCameraManager);
    }

    public void Stop()
    {
        LibcameraNative.CameraManagerStop(_nativeCameraManager);
    }

    public CameraList GetCameras()
    {
        var cameraListPtr = LibcameraNative.CameraManagerCameras(_nativeCameraManager);
        return new CameraList(cameraListPtr);
    }

    #region Dispose
    ~CameraManager() => Dispose(false);

    // Public implementation of Dispose pattern callable by consumers.
    public void Dispose()
    {
        Dispose(true);
        GC.SuppressFinalize(this);
    }

    // Protected implementation of Dispose pattern.
    protected virtual void Dispose(bool disposing)
    {
        if (!_disposedValue)
        {
            if (disposing)
            {
                // dispose managed state (managed objects)
            }

            // free unmanaged resources (unmanaged objects) and override finalizer
            LibcameraNative.CameraManagerDestroy(_nativeCameraManager);

            // set large fields to null
            _disposedValue = true;
        }
    }
    #endregion
}