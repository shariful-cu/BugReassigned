using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;
using System.Xml;
using HtmlAgilityPack;


namespace WindowsFormsApplication15
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }


        List<string> BugIds = new List<string>();
        List<string> CreationDates = new List<string>();
        Dictionary<string, string> Dic = new Dictionary<string, string>();
        Dictionary<string, string> DicProduct = new Dictionary<string, string>();
        Dictionary<string, string> DicComponent = new Dictionary<string, string>();
        int NumberOFEmtyBugs;




        private void button1_Click(object sender, EventArgs e)
        {
            //ExtractInformation();
            string TempDate = "";
            int dups = 0;
            int numberproduct = 0;
            int numbercomponent = 0;
            int GC=0;
            Dictionary<string, int> Priority = new Dictionary<string, int>();
            Dictionary<string, int> Severity = new Dictionary<string, int>();
            Dictionary<string, int> ProductReassignemntTime = new Dictionary<string, int>();
            Dictionary<string, int> ComponentReassignemntTime = new Dictionary<string, int>();

            List<string> ProductReassignemntTimeArray = new List<string>();
            List<string> ComponentReassignemntTimeArray = new List<string>();

            List<string> allPriorityChangeBugIds = new List<string>();
            List<string> allSeverityChangeBugIds = new List<string>();
            List<string> allVersionChangeBugIds = new List<string>();
            List<string> allStatusChangeBugIds = new List<string>();
            List<string> allResolutionChangeBugIds = new List<string>();
            List<string> allOSChangeBugIds = new List<string>();
            List<string> allAssigneChangeBugIds = new List<string>();
            List<string> allProductChangeBugIds = new List<string>();
            List<string> allComponentChangeBugIds = new List<string>();


            string[] Files=Directory.GetFiles(textBox1.Text);
           
            foreach (string file in Files)
            {
                 string LastProductSeen = "";
                try
                {
                    string opentime = "";
                    string LastProductChange = "";
                    string LastComponentChange = "";
                    bool isFirstRow = true;
                    bool Resolvedseen = false;
                    int docnt = 0;
                    StreamReader Reader = new StreamReader(file);
                    String temp = Reader.ReadToEnd();
                    HtmlAgilityPack.HtmlDocument doc = new HtmlAgilityPack.HtmlDocument();
                    doc.LoadHtml(temp);
                    if (temp.Contains("does not exist"))
                        GC++;
                    if (temp.Contains("DUPLICATE"))
                        dups++;
                    HtmlAgilityPack.HtmlNode Element = doc.GetElementbyId("bugzilla-body");
                    HtmlAgilityPack.HtmlNodeCollection XNL = Element.ChildNodes;
                    HtmlNode Table = XNL[3];
                    if (Table.Name != "table")
                        continue;
                    if (temp.Contains("You are not authorized"))
                    {
                        continue;
                    }
                    for (int i = 0; i < Table.ChildNodes.Count; i++)
                    {
                        if (Table.ChildNodes[i].Name == "#text")
                        {
                            continue;
                        }
                        bool PrioritySeen = false;
                        bool versionseen = false;
                        bool Severityseen = false;
                        bool Statusseen = false;
                        bool Resseen = false;
                        bool OSseen = false;
                        bool AssigneeSeen = false;
                        bool ProductSeen = false;
                        bool ComponentSeen = false;
                        foreach (HtmlNode td in Table.ChildNodes[i].ChildNodes)
                        {


                            if (td.Name == "#text")
                            {
                                continue;
                            }


                            if (Table.ChildNodes[i].ChildNodes[3].InnerText[0] == '2' && Table.ChildNodes[i].ChildNodes[3].InnerText[1] == '0' && Table.ChildNodes[i].ChildNodes[3].InnerText.Contains("-"))
                                TempDate = Table.ChildNodes[i].ChildNodes[3].InnerText;
                            if (isFirstRow && Table.ChildNodes[i].ChildNodes[3].InnerText != "When")
                            {
                                opentime = Table.ChildNodes[i].ChildNodes[3].InnerText;
                                isFirstRow = false;
                            }
                            if (td.InnerText.Contains("Priority"))
                            {
                                PrioritySeen = true;
                                numberproduct++;
                                LastProductChange = TempDate;
                            }
                            else if (PrioritySeen)
                            {
                                if (td.InnerText != "")
                                {
                                    if (!allPriorityChangeBugIds.Contains(file.Split('\\')[file.Split('\\').Length - 1]))
                                    {
                                        allPriorityChangeBugIds.Add(file.Split('\\')[file.Split('\\').Length - 1]);
                                    }
                                    if (!Priority.ContainsKey(td.InnerText))
                                    {
                                        Priority.Add(td.InnerText, 1);
                                    }
                                    else
                                    {
                                        Priority[td.InnerText]++;
                                    }
                                   // LastProductSeen = td.InnerText;
                                }
                            }


                            if (td.InnerText.Contains("Severity"))
                            {
                               
                                Severityseen = true;
                                numbercomponent++;
                                LastComponentChange = TempDate;
                            }
                            else if (Severityseen)
                            {
                               /* string prod = "";
                                if (LastProductSeen == "")
                                {
                                    if (DicProduct.ContainsKey(file.Split('\\')[file.Split('\\').Length - 1]))
                                    {
                                        prod = DicProduct[file.Split('\\')[file.Split('\\').Length - 1]];
                                    }
                                }*/
                               
                                if (td.InnerText != "")
                                {
                                    if (!allSeverityChangeBugIds.Contains(file.Split('\\')[file.Split('\\').Length - 1]))
                                    {
                                        allSeverityChangeBugIds.Add(file.Split('\\')[file.Split('\\').Length - 1]);
                                    }
                                    //if (!Component.ContainsKey(prod+"."+td.InnerText))
                                    if (!Severity.ContainsKey(td.InnerText))
                                    {
                                        //Component.Add(prod + "." + td.InnerText, 1);
                                        Severity.Add(td.InnerText, 1);
                                    }
                                    else
                                    {
                                        //Component[prod + "." + td.InnerText]++;
                                        Severity[td.InnerText]++;
                                    }
                                }
                            }

                            if (td.InnerText.Contains("Version"))
                            {
                                versionseen = true;
                            }
                            else if (versionseen)
                            {
                                if (td.InnerText != "")
                                {
                                    if (!allVersionChangeBugIds.Contains(file.Split('\\')[file.Split('\\').Length - 1]))
                                    {
                                        allVersionChangeBugIds.Add(file.Split('\\')[file.Split('\\').Length - 1]);
                                    }
                                    // LastProductSeen = td.InnerText;
                                }
                            }


                            if (td.InnerText.Contains("Status"))
                            {
                                Statusseen = true;
                            }
                            else if (Statusseen && docnt <= 1)
                            {
                                if (td.InnerText != "")
                                {
                                    if (Resolvedseen && td.InnerText.Contains("REOPEN"))
                                    {
                                        if (!allStatusChangeBugIds.Contains(file.Split('\\')[file.Split('\\').Length - 1]))
                                        {
                                            allStatusChangeBugIds.Add(file.Split('\\')[file.Split('\\').Length - 1]);
                                        }
                                    }
                                    else
                                    {
                                        docnt++;
                                    }
                                    if (td.InnerText.Contains("RESOLVED") || td.InnerText.Contains("CLOSED"))
                                        Resolvedseen = true;

                                    // LastProductSeen = td.InnerText;
                                }
                            }
                            else
                                docnt = 0;

                            if (td.InnerText.Contains("Resolution"))
                            {
                                Resseen = true;
                            }
                            else if (Resseen)
                            {
                                if (td.InnerText != "")
                                {
                                    if (!allResolutionChangeBugIds.Contains(file.Split('\\')[file.Split('\\').Length - 1]))
                                    {
                                        allResolutionChangeBugIds.Add(file.Split('\\')[file.Split('\\').Length - 1]);
                                    }
                                    // LastProductSeen = td.InnerText;
                                }
                            }

                            if (td.InnerText.Trim()=="OS")
                            {
                                OSseen = true;
                            }
                            else if (OSseen)
                            {
                                if (td.InnerText != "")
                                {
                                    if (!allOSChangeBugIds.Contains(file.Split('\\')[file.Split('\\').Length - 1]))
                                    {
                                        allOSChangeBugIds.Add(file.Split('\\')[file.Split('\\').Length - 1]);
                                    }
                                    // LastProductSeen = td.InnerText;
                                }
                            }

                            if (td.InnerText.Contains("Assignee"))
                            {
                                AssigneeSeen = true;
                            }
                            else if (AssigneeSeen)
                            {
                                if (td.InnerText != "")
                                {
                                    if (!allAssigneChangeBugIds.Contains(file.Split('\\')[file.Split('\\').Length - 1]))
                                    {
                                        allAssigneChangeBugIds.Add(file.Split('\\')[file.Split('\\').Length - 1]);
                                    }
                                    // LastProductSeen = td.InnerText;
                                }
                            }

                            if (td.InnerText.Contains("Product"))
                            {
                                ProductSeen = true;
                            }
                            else if (ProductSeen)
                            {
                                if (td.InnerText != "")
                                {
                                    if (!allProductChangeBugIds.Contains(file.Split('\\')[file.Split('\\').Length - 1]))
                                    {
                                        allProductChangeBugIds.Add(file.Split('\\')[file.Split('\\').Length - 1]);
                                    }
                                    // LastProductSeen = td.InnerText;
                                }
                            }


                            if (td.InnerText.Contains("Component"))
                            {
                                ComponentSeen = true;
                            }
                            else if (ComponentSeen)
                            {
                                if (td.InnerText != "")
                                {
                                    if (!allComponentChangeBugIds.Contains(file.Split('\\')[file.Split('\\').Length - 1]))
                                    {
                                        allComponentChangeBugIds.Add(file.Split('\\')[file.Split('\\').Length - 1]);
                                    }
                                    // LastProductSeen = td.InnerText;
                                }
                            }


                        }
                    }


                    /*if (Dic.ContainsKey(file.Split('\\')[file.Split('\\').Length - 1]))
                    {
                        DateTime FirstDate = Convert.ToDateTime(Dic[file.Split('\\')[file.Split('\\').Length - 1]]);

                        if (LastProductChange != "")
                        {
                            LastProductChange = LastProductChange.Replace("EDT", "");
                            LastProductChange = LastProductChange.Replace("EST", "");
                            DateTime ProductSecondDate = Convert.ToDateTime(LastProductChange);

                            ProductReassignemntTimeArray.Add((ProductSecondDate - FirstDate).TotalMinutes.ToString());
                            if (ProductReassignemntTime.ContainsKey((ProductSecondDate - FirstDate).TotalMinutes.ToString()))
                            {
                                ProductReassignemntTime[(ProductSecondDate - FirstDate).TotalMinutes.ToString()]++;
                                MessageBox.Show(file.Split('\\')[file.Split('\\').Length - 1]+" "+(ProductSecondDate - FirstDate).TotalMinutes.ToString());
                            }
                            else
                            {
                                ProductReassignemntTime.Add((ProductSecondDate - FirstDate).TotalMinutes.ToString(), 1);
                                MessageBox.Show(file.Split('\\')[file.Split('\\').Length - 1]+" "+(ProductSecondDate - FirstDate).TotalMinutes.ToString());
                            }
                        }

                        if (LastComponentChange != "")
                        {
                            LastComponentChange = LastComponentChange.Replace("EDT", "");
                            LastComponentChange = LastComponentChange.Replace("EST", "");
                            DateTime ComponentSecondDate = Convert.ToDateTime(LastComponentChange);
                            ComponentReassignemntTimeArray.Add((ComponentSecondDate - FirstDate).TotalMinutes.ToString());
                            if (ComponentReassignemntTime.ContainsKey((ComponentSecondDate - FirstDate).TotalMinutes.ToString()))
                            {
                                ComponentReassignemntTime[DicProduct[file.Split('\\')[file.Split('\\').Length - 1]]+" "+(ComponentSecondDate - FirstDate).TotalMinutes.ToString()]++;
                                MessageBox.Show(file.Split('\\')[file.Split('\\').Length - 1] + " " + (ComponentSecondDate - FirstDate).TotalMinutes.ToString());
                            }
                            else
                            {
                                ComponentReassignemntTime.Add(DicProduct[file.Split('\\')[file.Split('\\').Length - 1]]+" "+(ComponentSecondDate - FirstDate).TotalMinutes.ToString(), 1);
                                MessageBox.Show(file.Split('\\')[file.Split('\\').Length - 1] + " " + (ComponentSecondDate - FirstDate).TotalMinutes.ToString());
                            }
                        }
                    }*/


                }
                catch (Exception e1)
                {

                }
            }



            StreamWriter d = new StreamWriter("AllVersionReassigned");
            foreach (string entry in allVersionChangeBugIds)
            {
                d.WriteLine(entry);
            }
            d.Close();


            StreamWriter c = new StreamWriter("AllStatusReassigned");
            foreach (string entry in allStatusChangeBugIds)
            {
                c.WriteLine(entry);
            }
            c.Close();

            StreamWriter b = new StreamWriter("AllResolutionReassigned");
            foreach (string entry in allResolutionChangeBugIds)
            {
                b.WriteLine(entry);
            }
            b.Close();

            StreamWriter a = new StreamWriter("AllOSReassigned");
            foreach (string entry in allOSChangeBugIds)
            {
                a.WriteLine(entry);
            }
            a.Close();

            StreamWriter wr936 = new StreamWriter("AllPriorityReassigned");
            foreach (string entry in allPriorityChangeBugIds)
            {
                wr936.WriteLine(entry);
            }
            wr936.Close();

            StreamWriter write0 = new StreamWriter("allSeverityReassigne");
            foreach (string entry in allSeverityChangeBugIds)
            {
                write0.WriteLine(entry);
            }

            StreamWriter wr23 = new StreamWriter("AllproductReassigned");
            foreach (string entry in allProductChangeBugIds)
            {
                wr23.WriteLine(entry);
            }
            wr23.Close();

            StreamWriter write0712= new StreamWriter("allcomponentReassigne");
            foreach (string entry in allComponentChangeBugIds)
            {
                write0712.WriteLine(entry);
            }
            write0712.Close();
            StreamWriter writtt = new StreamWriter("alllAssigneReassigne");
            foreach (string entry in allAssigneChangeBugIds)
            {
                writtt.WriteLine(entry);
            }
            writtt.Close();


          


           /* StreamWriter write1 = new StreamWriter("ProductCountstatistics");
            foreach (KeyValuePair<string, int> entry in Product)
            {
                write1.WriteLine(entry.Key + "     " + entry.Value.ToString() + "     ");
            }
            write1.Close();

            StreamWriter write2 = new StreamWriter("ComponentCountstatistics");
            foreach (KeyValuePair<string, int> entry in Component)
            {
                write2.WriteLine(entry.Key + "     " + entry.Value.ToString() + "     ");
            }
            write2.Close();

            StreamWriter write3 = new StreamWriter("ProductDaystatistics");
            foreach (KeyValuePair<string, int> entry in ProductReassignemntTime)
            {
                write3.WriteLine(entry.Key + "     " + entry.Value.ToString() + "     ");
            }
            write3.Close();

            StreamWriter write4 = new StreamWriter("ComponentDaystatistics");
            foreach (KeyValuePair<string, int> entry in ComponentReassignemntTime)
            {
                write4.WriteLine(entry.Key + "     " + entry.Value.ToString() + "     ");
            }
            write4.Close();


            StreamWriter write5 = new StreamWriter("ProductDaystatisticsArray");
            foreach (string entry in ProductReassignemntTimeArray)
            {
                write5.WriteLine(entry);
            }
            write5.Close();

            StreamWriter write6 = new StreamWriter("ComponentDaystatisticsArray");
            foreach (string entry in ComponentReassignemntTimeArray)
            {
                write6.WriteLine(entry);
            }
            write6.Close();*/
          

            MessageBox.Show("Number of Component Changes "+numbercomponent.ToString());
            MessageBox.Show("Number of Product Changes "+numberproduct.ToString());
            MessageBox.Show("Number of Empty Bugs "+GC.ToString());
            MessageBox.Show("Number of Duplicates "+dups.ToString());
        }
    }
}

