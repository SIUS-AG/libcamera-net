using System.Runtime.InteropServices;
using System.Runtime.InteropServices.Marshalling;
using Microsoft.Win32.SafeHandles;

namespace Bld.LibcameraNet.Interop.Libc;

public static partial class LibcNative
{
    private const string LibName = "libc";

    public const ulong DMA_HEAP_IOCTL_ALLOC = 3222816768;
    public const ulong DMA_BUF_SET_NAME = 1074291201;

    [LibraryImport(
        LibName,
        EntryPoint = "lseek64",
        SetLastError = true)]
    internal static partial UInt64 Lseek64(int fd, long offset, WhenceFlags whence);

    [LibraryImport(
        LibName,
        EntryPoint = "mmap64",
        SetLastError = true)]
    internal static partial IntPtr Mmap64(
        IntPtr start,
        UIntPtr length,
        MmapProts prot,
        MmapFlags flags,
        int fd,
        long offset);

    [LibraryImport(
        LibName,
        EntryPoint = "open",
        StringMarshalling = StringMarshalling.Utf8,
        SetLastError = true)]
    internal static partial int Open(string filename, OpenFlags flags, int mode);

    [LibraryImport(
        LibName,
        EntryPoint = "ioctl",
        StringMarshalling = StringMarshalling.Utf8,
        SetLastError = true)]
    public static unsafe partial int Ioctl(int fd, ulong cmd, DmaHeapAllocationData* data);

    [LibraryImport(
        LibName,
        EntryPoint = "ioctl",
        StringMarshalling = StringMarshalling.Utf8,
        SetLastError = true)]
    public static unsafe partial int Ioctl(int fd, ulong cmd, [MarshalAs(UnmanagedType.LPUTF8Str)]string data);
}