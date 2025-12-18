using Bld.LibcameraNet;

namespace Bld.LibcameraNet.Example
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Creating camera manager");
            using var cameraManager = new CameraManager();
            Console.WriteLine("Camera manager created");
            
            cameraManager.Start();
            Console.WriteLine("Camera manager started");

            using var cameraList = cameraManager.GetCameras();
            Console.WriteLine($"Found {cameraList.Count} cameras");
        }
    }
}
