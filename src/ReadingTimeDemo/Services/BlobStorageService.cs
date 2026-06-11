using Azure.Storage.Blobs;
using Microsoft.Extensions.Configuration;

namespace ReadingTimeDemo.Services
{
    /// <summary>
    /// Provides Azure Blob Storage URLs for static web assets.
    /// The underlying BlobServiceClient is authenticated via DefaultAzureCredential (Managed Identity).
    /// Registered as Singleton in DI (per Rule 26: Azure SDK clients must be Singleton).
    /// </summary>
    public class BlobStorageService : IBlobStorageService
    {
        private readonly BlobServiceClient _blobServiceClient;
        private readonly string _containerName;

        public BlobStorageService(BlobServiceClient blobServiceClient, IConfiguration configuration)
        {
            _blobServiceClient = blobServiceClient;
            _containerName = configuration["Storage:StaticAssetsContainerName"] ?? "static-assets";
        }

        /// <inheritdoc />
        public string GetStaticAssetUrl(string assetPath)
        {
            var containerClient = _blobServiceClient.GetBlobContainerClient(_containerName);
            var blobClient = containerClient.GetBlobClient(assetPath);
            return blobClient.Uri.ToString();
        }
    }
}
