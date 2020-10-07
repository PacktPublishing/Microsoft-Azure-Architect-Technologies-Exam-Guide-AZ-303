using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;

namespace HelloWorldWebJob
{
    public class Functions
    {
        public static void ProcessQueueMessage([QueueTrigger("webjob")] string message, ILogger logger)
        {
            logger.LogInformation(message);
        }
    }
}
