@RestResource(urlMapping='/projectUpdates')
global class API_Customer_ProjectUpdates {

    @HttpGet
    global static void getConstructionUpdates() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        res.statusCode = 200;
        
        String projectName = RestContext.request.params.get('projectName');
        if (String.isBlank(projectName)) {
            res.responseBody = Blob.valueOf('{"error":"Missing required parameter: projectName"}');
            res.statusCode = 400;
            return;
        }
        
        Date sixMonthsAgo = Date.today().addMonths(-6);
        List<Construction_Update__c> updates = [
            SELECT Id, Update_Month__c, Project__c, Image_Url__c, Video_Url__c,
            Project_Updates__r.Unit__c,
            Project_Updates__r.Towers__c
            FROM Construction_Update__c
            WHERE Project__c = :projectName
            AND Update_Month__c >= :sixMonthsAgo
            ORDER BY Update_Month__c DESC
        ];
        Map<String, String> unitMap = new Map<String, String>();
        Map<String, String> towerDetailsMap = new Map<String, String>();
        List<Ramky_Projects__mdt> UnitDetails = [SELECT Id, MasterLabel, Unit__c, Tower__c FROM Ramky_Projects__mdt WHERE MasterLabel =:projectName];
        for (Ramky_Projects__mdt customerDetails : UnitDetails) {
            unitMap.put(customerDetails.MasterLabel, customerDetails.Unit__c != null ? customerDetails.Unit__c :'');
            towerDetailsMap.put(customerDetails.MasterLabel, customerDetails.Tower__c != null ? customerDetails.Tower__c :'');
        }
        if (updates.isEmpty()) {
            res.responseBody = Blob.valueOf('{"message":"No construction updates found."}');
            return;
        }
        Construction_Update__c first = updates[0];
        ProjectUpdateWrapper wrapper = new ProjectUpdateWrapper();
        wrapper.project = new ProjectWrapper(
            first.Project__c,
            new UnitDetails(unitMap.get(first.Project__c), 
                            towerDetailsMap.get(first.Project__c)),
            new List<MonthlyUpdate>()
        );
        
        for (Construction_Update__c upd : updates) {
            List<ImageWrapper> images = new List<ImageWrapper>();
            List<VideoWrapper> videos = new List<VideoWrapper>();
            // Process Image_Url__c (comma-separated list)
            if (!String.isBlank(upd.Image_Url__c)) {
                List<String> urlList = upd.Image_Url__c.split(',');
                for (String rawUrl : urlList) {
                    String imageUrl = rawUrl.trim();
                    if (!String.isBlank(imageUrl)) {
                        images.add(new ImageWrapper(imageUrl));
                    }
                }
            }
            
            // Process Video_Url__c (single URL, assume it is full or comma-separated if needed)
            if (!String.isBlank(upd.Video_Url__c)) {
                List<String> videoList = upd.Video_Url__c.split(',');
                for (String rawVideoUrl : videoList) {
                    String videoUrl = rawVideoUrl.trim();
                    if (!String.isBlank(videoUrl)) {
                        String thumbnailUrl = videoUrl.replace('.mp4', '.jpg');
                        videos.add(new VideoWrapper(thumbnailUrl, videoUrl));
                    }
                }
            }
            
            String formattedMonth = upd.Update_Month__c != null
                ? DateTime.newInstance(upd.Update_Month__c, Time.newInstance(0, 0, 0, 0)).format('MMMM yyyy')
                : 'Unknown';
            
            wrapper.project.updates.add(
                new MonthlyUpdate(formattedMonth, new MediaWrapper(images, videos))
            );
        }
        
        res.responseBody = Blob.valueOf(JSON.serialize(wrapper));
    }
    
    
    // === Wrapper Classes ===
    
    global class ProjectUpdateWrapper {
        public ProjectWrapper project;
    }
    
    global class ProjectWrapper {
        public String name;
        public UnitDetails unit_details;
        public List<MonthlyUpdate> updates;
        public ProjectWrapper(String n, UnitDetails u, List<MonthlyUpdate> ups) {
            name = n; unit_details = u; updates = ups;
        }
    }
    
    global class UnitDetails {
        public String Unit;
        public String Towers;
        public UnitDetails(String u, String t) { Unit = u; Towers = t; }
    }
    
    global class MonthlyUpdate {
        public String month;
        public MediaWrapper media;
        public MonthlyUpdate(String m, MediaWrapper md) { month = m; media = md; }
    }
    
    global class MediaWrapper {
        public List<ImageWrapper> images;
        public List<VideoWrapper> videos;
        public MediaWrapper(List<ImageWrapper> i, List<VideoWrapper> v) { images = i; videos = v; }
    }
    
    global class ImageWrapper {
        public String thumbnail_url;
        public ImageWrapper(String u) { thumbnail_url = u; }
    }
    
    global class VideoWrapper {
        public String thumbnail_url;
        public String video_url;
        public VideoWrapper(String thumb, String video) {
            thumbnail_url = thumb;
            video_url = video;
        }
    }
}