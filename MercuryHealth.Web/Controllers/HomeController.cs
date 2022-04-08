using MercuryHealth.Web.Data;
using MercuryHealth.Web.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.FeatureManagement;
using Microsoft.FeatureManagement.Mvc;
using System.Diagnostics;
using Microsoft.Extensions.Options;

namespace MercuryHealth.Web.Controllers;

public class HomeController : Controller
{
    private readonly MercuryHealthWebContext _context;
    readonly IFeatureManager _featureManager;
    private readonly Settings _settings;
    private readonly IConfiguration _configuration;

    public HomeController(MercuryHealthWebContext context, IConfiguration Configuration, IFeatureManagerSnapshot featureManager, IOptionsSnapshot<Settings> settings)
    {
        _featureManager = featureManager;
        _context = context;
        _settings = settings.Value;
        _configuration = Configuration;
    }

    public IActionResult Index()
    {
        // Todo: Mock setup for Config and so forth and so on...
        // 
        ViewData["myenvironment"] = _configuration["deployedenvironment"];
        ViewData["FontSize"] = _settings.FontSize;
        ViewData["FontColor"] = _settings.FontColor;
        ViewData["BackGroundColor"] = _settings.BackGroundColor;

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

    //[FeatureGate("PrivacyBeta")]
    [FeatureGate(MyFeatureFlags.PrivacyBeta)]
    public async Task<IActionResult> PrivacyBeta()
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

    // Check for Feature Flag
    // If Feature Flag is disabled, the entire method is disabled.
    [FeatureGate("MetricsDashboard")]
    public IActionResult Metrics()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
