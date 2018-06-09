using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Net;
using System.IO;

namespace EclipseActivityDownloader
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            for (int i = 1; i < 752300; i++)
            {
                Uri address = new Uri("https://bugzilla.gnome.org/show_activity.cgi?id=" + i.ToString());
                HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create(address);
                request.Method = "GET";
                request.KeepAlive = true;
                request.UserAgent = "Foo";
                request.Accept = "*/*";
                HttpWebResponse response = (HttpWebResponse)request.GetResponse();
                StreamReader Reader = new StreamReader(response.GetResponseStream());
                StreamWriter w = new StreamWriter(i.ToString());
                w.Write(Reader.ReadToEnd());
                w.Close();
            }
        }
    }
}
