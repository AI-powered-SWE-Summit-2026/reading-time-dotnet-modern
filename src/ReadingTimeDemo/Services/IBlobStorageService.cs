namespace ReadingTimeDemo.Services
{
    public interface IBlobStorageService
    {
        /// <summary>
        /// Returns the full Azure Blob Storage URL for the given static asset path.
        /// </summary>
        /// <param name="assetPath">Relative path of the asset within the static assets container (e.g. "images/covers/scrum.jpg").</param>
        string GetStaticAssetUrl(string assetPath);
    }
}
