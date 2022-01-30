using System.Reflection;

namespace MercuryHealth.Web;

public class MyAppVersion
{
    public static string GetAssemblyVersion()
    {
        //return GetType().Assembly.GetName().Version.ToString();
        return Assembly.GetEntryAssembly().GetCustomAttribute<AssemblyFileVersionAttribute>().Version;
    }

    public static string GetDateTimeFromVersion()
    {
        string myAssemblyVersion = GetAssemblyVersion();

        // Split Major.Minor.Build.Revision
        string[] myVersion = myAssemblyVersion.Split('.');

        // Base date that build revision number is generated from
        DateTime baseDate = new DateTime(2022, 1, 1, 0, 0, 0);

        // #of Days from Revision #
        int numOfDays = Convert.ToInt32(myVersion[2]);

        // #of Seconds from Midnight
        int numOfSecs = Convert.ToInt32(myVersion[3]) * 2;

        // Add #of days to base date
        DateTime myModifedDate = baseDate.AddDays(numOfDays);

        // Add #of of seconds from Midnight
        myModifedDate = myModifedDate.AddSeconds(numOfSecs);

        string ReturnDateTimeFromVersion = myModifedDate.ToShortDateString() + " at " + myModifedDate.ToShortTimeString();

        return ReturnDateTimeFromVersion;

    }
}

