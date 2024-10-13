import axios from "axios";
import cheerio from 'cheerio';
import { ServiceResponse } from "./base.service";

interface MetadataResponse extends ServiceResponse {
    title?: string;
    thumbnailUrl?: string;
}

class ExtResService {

    /**
     * Initialize ExtResService
     */
    public constructor() {
    }

    /**
     * Handle signup feature
     * @param {string} url - the link to the article or videos
     * @returns {MetadataResponse} - an object describing whether signing up is successful or not, and associated messages, and errors
     */
    public async scrapeMetadata(url: string): Promise<MetadataResponse> {
        try {
            const response = await axios.get(url);
    
            // Load the HTML content into Cheerio
            const $ = cheerio.load(response.data);
    
            // Extract the title
            const title = $('meta[property="og:title"]').attr('content');
    
            // Extract the thumbnail (change the selector as needed)
            const thumbnailUrl = $('meta[property="og:image"]').attr('content');
    
            return {
                success: true, message: "metadata scraped",
                title, thumbnailUrl
            };
        } catch (error) {
            return { success: false, error };
        }
    }
}

export {
    ExtResService, MetadataResponse
};
