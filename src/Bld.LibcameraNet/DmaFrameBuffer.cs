namespace Bld.LibcameraNet;

public class DmaFrameBuffer
{
    private readonly int _allocFd;

    public DmaFrameBuffer(int allocFd)
    {
        _allocFd = allocFd;
    }
}