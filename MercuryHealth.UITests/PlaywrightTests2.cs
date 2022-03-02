using System;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Playwright;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using NUnit.Framework;
using Assert = NUnit.Framework.Assert;
using TestContext = NUnit.Framework.TestContext;

namespace MercuryHealth.UITests
{
    [TestFixture]
    [TestClass]
    public class PlaywrightTests2
    {
        //private TestContext testContextInstance;
        private string appURL = "https://app-btocbms4557so-dev.azurewebsites.net/";
        private string myPageTitle = "";

        //public TestContext TestContext
        //{
        //    get
        //    {
        //        return testContextInstance;
        //    }
        //    set
        //    {
        //        testContextInstance = value;
        //    }
        //}

        [TestInitialize()]
        public void SetupTest()
        {
            // The following line installs the default browsers. If you only need a subset of browsers,
            // you can specify the list of browsers you want to install among: chromium, chrome,
            // chrome-beta, msedge, msedge-beta, msedge-dev, firefox, and webkit.
            // var exitCode = Microsoft.Playwright.Program.Main(new[] { "install", "webkit", "chrome" });
            var exitCode = Microsoft.Playwright.Program.Main(new[] { "install", "chromium", "firefox" });
            if (exitCode != 0)
            {
                throw new Exception($"Playwright exited with code {exitCode}");
            }
        }

        [TestMethod]
        [TestCategory("Playwright_Tests_Chromium")]
        public void VerifyWebAppUrlParameter()
        {
            string webAppUrl = TestContext.Parameters["WebAppUrl"];
            //var code = TestContext.Parameters.Get("WebAppUrl", "http://localhost");

            Assert.AreEqual("http://localhostXYZ", webAppUrl);
        }

        [TestMethod]
        [TestCategory("Playwright_Tests_Chromium")]
        public async Task TheBingSearchTestAsync()
        {
            //const string ParameterName = "webAppURL";
            //appURL = TestContext.Properties[ParameterName]);

            //appURL = "https://www.bing.com/";
            using var playwright = await Playwright.CreateAsync();
            await using var browser = await playwright.Chromium.LaunchAsync();
            var page = await browser.NewPageAsync();
            page.SetDefaultTimeout(30000);

            await page.GotoAsync(appURL);

            myPageTitle = await page.TitleAsync();
            Assert.AreEqual("Bing", myPageTitle);
        }

        //[TestMethod]
        //[TestCategory("Playwright_Tests_Chromium")]
        //public void SampleTest()
        //{
        //    const string ParameterName = "password";
        //    const string ExpectedValue = "secret";
        //    Assert.AreEqual(ExpectedValue, TestContext.Properties[ParameterName]);
        //}

        /// <summary>
        ///Gets or sets the test context which provides
        ///information about and functionality for the current test run.
        ///</summary>

        [TestCleanup()]
        public void MyTestCleanup()
        {
//            driver.Quit();
        }
    }
}
