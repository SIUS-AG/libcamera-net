using Bld.LibcameraNet.Interop.Libc;
using Microsoft.Win32.SafeHandles;

namespace Bld.LibcameraNet;

public class RaspberryPiFrameBufferAllocator
{
    private readonly List<string> _heapNames =
    [
        "/dev/dma_heap/vidbuf_cached",
        "/dev/dma_heap/linux,cma",
    ];
    private readonly int dmaHeapHandle_;

    public RaspberryPiFrameBufferAllocator()
    {
        foreach (var name in _heapNames)
        {
            var ret = LibcNative.Open(
                name,
                OpenFlags.O_RDWR | OpenFlags.O_CLOEXEC,
                0);
            if (ret < 0)
            {
                //LOG(2, "Failed to open " << name << ": " << ret);
                continue;
            }

            dmaHeapHandle_ = ret;
            break;
        }

        //if (!dmaHeapHandle_.isValid())
        //    LOG_ERROR("Could not open any dmaHeap device");
    }

    public DmaFrameBuffer? Alloc(string name, UInt64 size)
    {
        int ret;

        if (string.IsNullOrWhiteSpace(name))
        {
            return null;
        }

        var alloc = new DmaHeapAllocationData
        {
            Len = size,
            FdFlags = (uint)(OpenFlags.O_CLOEXEC | OpenFlags.O_RDWR)
        };

        unsafe
        {
            ret = LibcNative.Ioctl(dmaHeapHandle_, LibcNative.DMA_HEAP_IOCTL_ALLOC, &alloc);
        }

        if (ret < 0)
        {
            //LOG_ERROR("dmaHeap allocation failure for " << name);
            return null;
        }


        var allocFd = alloc.Fd;
        ret = LibcNative.Ioctl((int)allocFd, LibcNative.DMA_BUF_SET_NAME, name);
	    if (ret < 0)
	    {
		    //LOG_ERROR("dmaHeap naming failure for " << name);
		    return null;
	    }

	    return new DmaFrameBuffer((int)allocFd);
    }
}