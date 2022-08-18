using MercuryHealth.Web;
using Microsoft.ApplicationInsights.Channel;
using Microsoft.ApplicationInsights.DataContracts;
using Microsoft.ApplicationInsights.Extensibility;

namespace MercuryHealth.Web;

public class StartupHelper
{ 

    //public class CloneIPAddress : ITelemetryInitializer
    //    {
    //        ISupportProperties propTelemetry = telemetry as ISupportProperties;

    //        if (propTelemetry != null && !propTelemetry.Properties.ContainsKey("client-ip"))
    //        {
    //            string clientIPValue = telemetry.Context.Location.Ip;
    //        propTelemetry.Properties.Add("client-ip", clientIPValue);
    //    public void Initialize(ITelemetry telemetry)
    //        {
    //            throw new NotImplementedException();
    //        }
    //}
    //}

    //public class AddAppVersion : ITelemetryInitializer
    //{
    //    public void Initialize(ITelemetry telemetry)
    //    {
    //        var requestTelemetry = telemetry as RequestTelemetry;

    //        // Set the Application Version from the *.dll assembly
    //        requestTelemetry.Properties.Add("AppVersion", MyAppVersion.GetAssemblyVersion());
    //    }
    //}

}
