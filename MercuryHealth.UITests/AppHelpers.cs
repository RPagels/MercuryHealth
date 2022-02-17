using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Playwright;

namespace MercuryHealth.UITests;

public class AppHelpers
{
    public static string GetURL()
    {
        var config = new ConfigurationBuilder().AddJsonFile("testsettings.json").Build();
        string urlpath = config["webAppUrl"];
        return urlpath;
    }

    public static async Task<IResponse> VisitURL(IPage page, string path = "/")
    {
        var config = new ConfigurationBuilder().AddJsonFile("testsettings.json").Build();
        string url = config["webAppUrl"] + path;
        return await page.GotoAsync(url);
    }

    public static async Task<string> VisitURLGetErrors(IPage page, string path = "/")
    {
        var errors = "";
        page.PageError += (_, exception) => { errors = errors + exception; };
        await VisitURL(page, path);
        return errors;
    }
}