using System;
using System.Diagnostics;
using System.IO;
using System.Text;

namespace PotPlayerLauncher
{
    static class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            try
            {
                string baseDir = AppDomain.CurrentDomain.BaseDirectory;
                string runAsDate = Path.Combine(baseDir, "RunAsDate.exe");
                string realPot = Path.Combine(baseDir, "PotPlayer64_Core.exe");

                if (!File.Exists(realPot))
                {
                    return;
                }

                StringBuilder sb = new StringBuilder();
                sb.Append("/immediate /movetime Hours:-17520 \"").Append(realPot).Append("\"");

                if (args != null && args.Length > 0)
                {
                    for (int i = 0; i < args.Length; i++)
                    {
                        string a = args[i];
                        if (!string.IsNullOrEmpty(a))
                        {
                            sb.Append(" \"").Append(a.Replace("\"", "\\\"")).Append("\"");
                        }
                    }
                }

                ProcessStartInfo psi = new ProcessStartInfo();
                psi.FileName = runAsDate;
                psi.Arguments = sb.ToString();
                psi.WorkingDirectory = baseDir;
                psi.UseShellExecute = false;
                psi.CreateNoWindow = true;
                psi.WindowStyle = ProcessWindowStyle.Hidden;

                Process.Start(psi);
            }
            catch {}
        }
    }
}
