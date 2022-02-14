using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Playwright;
using NUnit.Framework;

namespace MercuryHealth.UITests

{
    public class Tests
    {
        [SetUp]
        public void Setup()
        {
        }

        [Test]
        public void Test1()
        {
            Assert.Pass();
        }

        string myPageTitle = "";
        string pageURL = "https://website-4vwxkvpofrtbq-dev.azurewebsites.net/";

        [Test]
        [Category("Playwright_Tests")]
        public async Task Verify_NavToHome()
        {
            // Go to home page
            //var page = await browser.NewPageAsync();
            using var playwright = await Playwright.CreateAsync();
            //await using var browser = await playwright.Chromium.LaunchAsync(new BrowserTypeLaunchOptions
            //{
            //    Headless = false,
            //});

            // comment

            await using var browser = await playwright.Chromium.LaunchAsync();
            var context = await browser.NewContextAsync();
            var page = await context.NewPageAsync();
            page.SetDefaultTimeout(30000);

            await page.GotoAsync(pageURL);

            // Click on the cookie policy acceptance button if it exists
            if ((await page.QuerySelectorAsync("#accept-policy close")) != null)
            {
                await page.ClickAsync("#accept-policy close");
            }

            myPageTitle = await page.TitleAsync();

            // Take screenshot & Add as Test Attachment
            await File.WriteAllBytesAsync(Path.Combine(Directory.GetCurrentDirectory(), "Home-Homepage.png"), await page.ScreenshotAsync());
            TestContext.AddTestAttachment(Path.Combine(Directory.GetCurrentDirectory(), "Home-Homepage.png"), "Home-Homepage.png");

            Assert.AreEqual("Home Page - Mercury Health", myPageTitle);

        }

    }
}

