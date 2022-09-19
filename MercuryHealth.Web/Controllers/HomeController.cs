using MercuryHealth.Web.Data;
using MercuryHealth.Web.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.FeatureManagement;
using Microsoft.FeatureManagement.Mvc;
using System.Diagnostics;
using Microsoft.Extensions.Options;
using System.Net;

namespace MercuryHealth.Web.Controllers;

public class HomeController : Controller
{
    private readonly MercuryHealthWebContext _context;
    readonly IFeatureManager _featureManager;
    private readonly PageSettings _pageSettings;
    private readonly IConfiguration _configuration;

    public HomeController(MercuryHealthWebContext context, IOptionsSnapshot<PageSettings> pageSettings, IConfiguration Configuration, IFeatureManagerSnapshot featureManager)
    {
        _featureManager = featureManager;
        _context = context;
        _pageSettings = pageSettings.Value;
        _configuration = Configuration;
    }

    public IActionResult Index()
    {
        // Save App Configuration Dynamic Update Settings
        ViewData["FontSize"] = _pageSettings.FontSize;
        ViewData["FontColor"] = _pageSettings.FontColor;
        ViewData["BackgroundColor"] = _pageSettings.BackgroundColor;

        // Save App Configuration Dynamic Configuration Settings
        ViewData["myenvironment"] = _configuration["DeployedEnvironment"];
        ViewData["Website_FontName"] = _configuration["WEBSITE_FONTNAME"];
        ViewData["Website_FontColor"] = _configuration["WEBSITE_FONTCOLOR"];
        ViewData["Website_FontSize"] = _configuration["WEBSITE_FONTSIZE"];

        //IPAddress remoteIpAddress = Request.HttpContext.Connection.RemoteIpAddress;

        List<AccessLogs> ObjAccessLogs = new List<AccessLogs>();

        // Insert new record for each page visit
        var query = new AccessLogs
        {
            PageName = "Home",
            AccessDate = DateTime.UtcNow
        };

        _context.AccessLogs.Add(query);
        _context.SaveChanges();

        int pagecount = (_context.AccessLogs.Where(x => x.PageName.Equals("Home")).Count());
        query = _context.AccessLogs.OrderByDescending(x => x.AccessDate).FirstOrDefault();
        DateTime pagevisit = query.AccessDate;

        AccessLogs Obj = new AccessLogs();
        Obj.PageName = "Home";
        Obj.AccessDate = pagevisit;
        Obj.Visits = pagecount;
        ObjAccessLogs.Add(Obj);

        // Are you really tired?  Take a break! :)
        Thread.Sleep(5000);

        return View(ObjAccessLogs.ToList());

    }

    public async Task<IActionResult> Privacy()
    {
        if (await _featureManager.IsEnabledAsync("PrivacyBeta"))
        {
            return View(new PrivacyModel { Name = "Privacy Beta" });
        }
        else
        {
            return View(new PrivacyModel { Name = "Privacy" });
        }
    }

    // Can completetly disable the class if flag turned off
    //[FeatureGate(MyFeatureFlags.PrivacyBeta)]
    //public async Task<IActionResult> PrivacyBeta()
    //{
    //    if (await _featureManager.IsEnabledAsync("PrivacyBeta"))
    //    {
    //        return View(new PrivacyModel { Name = "Privacy Beta" });
    //    }
    //    else
    //    {
    //        return View(new PrivacyModel { Name = "Privacy" });
    //    }
    //}

    // Check for Feature Flag
    // If Feature Flag is disabled, the entire method is disabled.
    [FeatureGate("MetricsDashboard")]
    public async Task<IActionResult> Metrics()
    {
        if (await _featureManager.IsEnabledAsync("MetricsDashboard"))
        {
            return View(new MetricsModel { Name = "Metrics Beta" });
        }
        else
        {
            return View(new MetricsModel { Name = "Metrics" });
        }
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
