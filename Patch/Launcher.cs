using System;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;

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

                // Self-healing: auto-clean poisoned 2025/2026/2027 StarForce locks
                try
                {
                    string appData = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
                    string jongan = Path.Combine(appData, @"DmitriRender\x64\Jongan.ini");
                    if (File.Exists(jongan))
                    {
                        string content = File.ReadAllText(jongan);
                        if (content.IndexOf("2025", StringComparison.OrdinalIgnoreCase) >= 0 ||
                            content.IndexOf("2026", StringComparison.OrdinalIgnoreCase) >= 0 ||
                            content.IndexOf("2027", StringComparison.OrdinalIgnoreCase) >= 0)
                        {
                            File.Delete(jongan);
                            Process pReg = Process.Start(new ProcessStartInfo("reg.exe", "delete \"HKCU\\Software\\DmitriRender\" /f") { CreateNoWindow = true, UseShellExecute = false });
                            if (pReg != null) pReg.WaitForExit();
                        }
                    }

                    string docs = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);
                    string desktopIni = Path.Combine(docs, "desktop.ini");
                    if (File.Exists(desktopIni))
                    {
                        string dContent = File.ReadAllText(desktopIni);
                        if (dContent.IndexOf("{", StringComparison.OrdinalIgnoreCase) >= 0)
                        {
                            File.SetAttributes(desktopIni, FileAttributes.Normal);
                            string clean = Regex.Replace(dContent, @"(?m)^(\{[0-9A-Fa-f\-]+\}|Class=.*)$[\r\n]*", "");
                            File.WriteAllText(desktopIni, clean);
                            File.SetAttributes(desktopIni, FileAttributes.System | FileAttributes.Hidden);
                        }
                    }
                }
                catch {}

                if (!File.Exists(realPot))
                {
                    return;
                }

                DateTime target = DateTime.Now.AddDays(-730);
                string dateStr = target.ToString(@"dd\\MM\\yyyy");
                string timeStr = target.ToString("HH:mm:ss");

                StringBuilder sb = new StringBuilder();
                sb.Append("/immediate /movetime \"").Append(dateStr).Append("\" \"").Append(timeStr).Append("\" \"").Append(realPot).Append("\"");

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

                Process.Start(psi);
            }
            catch {}
        }
    }
}
