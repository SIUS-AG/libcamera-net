namespace Bld.LibcameraNet.Interop.Libc;

[Flags]
internal enum OpenFlags
{
    // Access modes (mutually exclusive)
    O_RDONLY = 0x0000,
    O_WRONLY = 0x0001,
    O_RDWR = 0x0002,

    // Flags (combinable)
    O_CLOEXEC = 0x0010,
    O_CREAT = 0x0020,
    O_EXCL = 0x0040,
    O_TRUNC = 0x0080,
    O_SYNC = 0x0100,
    O_NOFOLLOW = 0x0200,
}