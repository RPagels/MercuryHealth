using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Playwright;

namespace MercuryHealth.UITests;

public class AppHelpers
{
    public static async Task<IResponse> VisitURL(IPage page, string path = "/")
    {
        var config = new ConfigurationBuilder().AddJsonFile("appsettings.json").Build();
        string url = config["BASE_URL"] + path;
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