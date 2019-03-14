using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;

namespace LockWorkstation
{
    class Natives
    {
        [DllImport("user32.dll")]
        public static extern int ExitWindowsEx(int uFlags, int dwReserved);
        [DllImport("user32.dll")]
        public static extern bool LockWorkStation();
    }
}
