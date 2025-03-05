using System.Runtime.InteropServices;

namespace Bld.LibcameraNet.Interop.Libc;

[StructLayout(LayoutKind.Sequential)]
public struct DmaHeapAllocationData
{
    public UInt64 Len;
    public UInt32 Fd;
    public UInt32 FdFlags;
    public UInt64 HeapFlags;
}