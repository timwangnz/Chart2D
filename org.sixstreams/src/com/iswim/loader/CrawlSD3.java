package com.iswim.loader;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import org.htmlparser.Node;
import org.htmlparser.NodeFilter;
import org.htmlparser.Parser;
import org.htmlparser.filters.LinkStringFilter;
import org.htmlparser.tags.LinkTag;
import org.htmlparser.util.NodeList;

import com.iswim.model.BestTime;
import com.iswim.model.Race;
import com.iswim.model.Team;

public class CrawlSD3 {

    protected static Logger sLogger = Logger.getLogger(CrawlSD3.class.getName());
    private static String LSC = "PC";

    List<String> sd3List = new ArrayList<String>();
    protected MeetLoader meetLoader;

    private static long teamCount = 0;
    private static long meetCount = 0;
    private static long raceCount = 0;

    public void scanZipFile(String zipname) {
        try {
            URL url = new URL(zipname);
            ZipInputStream zin = new ZipInputStream(url.openStream());
            ZipEntry entry;
            while ((entry = zin.getNextEntry()) != null) {
                System.out.println(entry.getName());
                zin.closeEntry();
            }
            zin.close();
        } catch (IOException e) {
            sLogger.severe("Exception when scan zip file " + e);
        }
    }

    public void processZipFile(String zipname) {
        if (zipname == null || zipname.length() == 0) {
            return;
        }
        try {
            URL url = new URL(zipname);
            ZipInputStream zin = new ZipInputStream(url.openStream());
            ZipEntry entry;
            boolean found = false;
            while ((entry = zin.getNextEntry()) != null) {
                if (entry.getName().toUpperCase().endsWith("CL2")) {
                    sLogger.info("Process " + entry.getName());
                    process(zin);
                    found = true;
                    break;
                }

                if (entry.getName().toUpperCase().endsWith("SD3")) {
                    sLogger.info("Process " + entry.getName());
                    process(zin);
                    found = true;
                    break;
                }
                if (entry.getName().toUpperCase().endsWith("ZIP")) {
                    sLogger.info("Process " + entry.getName());
                    processZipStream(zin);
                    found = true;
                    break;
                }
                zin.closeEntry();
            }
            zin.close();
            if (!found) {
                throw new Exception("No swim file found in the zip file " + zipname);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void processZipStream(InputStream stream) throws Exception {
        ZipInputStream zin = new ZipInputStream(stream);
        ZipEntry entry;
        boolean found = false;
        while ((entry = zin.getNextEntry()) != null) {
            if (entry.getName().toUpperCase().endsWith("CL2")) {
                sLogger.info("Process " + entry.getName());
                process(zin);
                found = true;
                break;
            }

            if (entry.getName().toUpperCase().endsWith("SD3")) {
                sLogger.info("Process " + entry.getName());
                process(zin);
                found = true;
                break;
            }
            zin.closeEntry();
        }
        zin.close();

        if (!found) {
            throw new Exception("No swim data found");
        }
    }

    public int crawl(String site, String[] pages, int max) {
        int i = 0;
        for (String page : pages) {
            i += crawl(site, page, max);
            if (i >= max && max != -1) {
                break;
            }
        }
        return i;
    }

    public int crawl(String site, String page, int max) {
        getListFromUrl(site, page);
        return process(max);
    }

    public void graph(String site, int current, int depth) {
        if (depth == current) {
            return;
        }
        String tabs = "";
        for (int i = 0; i < current; i++) {
            tabs += "\t";
        }
        for (String url : getLinks(site)) {
            sLogger.info(tabs + url);
            graph(url, current + 1, depth);
        }
    }

    public static class LinkFilter implements NodeFilter {

        private static final long serialVersionUID = 1L;

        public boolean accept(Node arg0) {
            return arg0 instanceof LinkTag;
        }

    }

    protected boolean isMeetCrawled(String meetName) {
        return false;
    }

    protected void saveMeetFile(String meetName) {
        //to be overridden	
    }

    int process(int max) {
        int crawled = 0;
        for (int i = 0; i < sd3List.size(); i++) {
            String sd3url = (String) sd3List.get(i);
            try {
                if (crawled >= max && max != -1) {
                    return crawled;
                }

                if (!isMeetCrawled(sd3url)) {
                    crawled++;
                    long time = System.currentTimeMillis();
                    processZipFile(sd3url);
                    saveMeetFile(sd3url);
                    sLogger.info("Crawled " + sd3url + " in " + (System.currentTimeMillis() - time));
                }
            } catch (Throwable e) {

                // remove meet
                e.printStackTrace();
            }
        }
        return crawled;
    }

    public List<String> getLinks(String url) {
        List<String> urls = new ArrayList<String>();
        try {
            Parser parser = new Parser(url);
            NodeList list = parser.parse(new LinkFilter());
            Node[] nodes = list.toNodeArray();
            for (int i = nodes.length - 1; i >= 0; i--) {
                Node node = nodes[i];
                LinkTag link = (LinkTag) node;
                urls.add(link.getLink());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return urls;
    }

    void getListFromUrl(String url, String page) {
        if (url.startsWith("file")) {
            getListFromFile(url, page);
        } else if (url.startsWith("http")) {
            getListFromWeb(url, page);
        }
    }

    public void getListFromFile(String url, String page) {
        try {
            if (url.startsWith("file://")) {
                url = url.substring("file://".length());
            }

            File rootDir = new File(url + "/" + page);
            if (rootDir.isDirectory()) {
                for (File file : rootDir.listFiles()) {
                    if (!file.isDirectory() && file.getAbsolutePath().toLowerCase().endsWith("zip")) {
                        sd3List.add("file://" + file.getAbsolutePath());
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void getListFromWeb(String url, String page) {
        try {
            Parser parser = new Parser(url + page);
            NodeList list = parser.parse(new LinkStringFilter("zip", false));
            Node[] nodes = list.toNodeArray();
            for (int i = nodes.length - 1; i >= 0; i--) {
                Node node = nodes[i];
                LinkTag link = (LinkTag) node;
                sd3List.add(link.getLink());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private URL getFileURL(String location) throws Exception {
        return new URL("file", "", -1, location);
    }

    public void process(String urlString) {
        try {
            URL url = getFileURL(urlString);
            process(url);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void process(URL url) {
        try {
            InputStream steam = url.openStream();
            process(steam);
            steam.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void process(InputStream stream) {
        try {
            raceCount = 0;
            BufferedReader br = new BufferedReader(new InputStreamReader(stream));
            Team team = null;
            while (true) {
                String line = br.readLine();
                //System.err.println(line);
                if (line == null) {
                    break;
                }
                if (line.startsWith("A0")) {
                    meetLoader = new MeetLoader(LSC, line);
                    meetCount++;
                } else if (line.startsWith("B1")) {
                    meetLoader.updateMeet(line);
                } else if (line.startsWith("B2")) {
                    meetLoader.addMeetHost(line);
                } else if (line.startsWith("C1")) {
                    team = meetLoader.addTeam(line);
                    teamCount++;
                } else if (line.startsWith("C2")) {
                    meetLoader.updateTeam(team, line);
                } else if (line.startsWith("D0")) {
                    raceCount++;
                    meetLoader.addRace(line);
                } else if (line.startsWith("D1")) {
                    // meetLoader.updateTeam(line);
                } else if (line.startsWith("D2")) {
                    // meetLoader.updateTeam(line);
                } else if (line.startsWith("D3")) {
                    meetLoader.updateSwimmer(team, line);
                }
            }
            br.close();
            sLogger.info("Processed total of " + raceCount);
            save();
        } catch (Throwable e) {
            //sendEmail("anpwang@gmail.com", "Failed to load data", e.getMessage());
            e.printStackTrace();
        }
    }

    public void index() {

    }

    public void save() {

    }

    public boolean equals(Race race, BestTime bestTime) {
        return race.getCourse().equals(bestTime.getCourse())
                && race.getDistance() == bestTime.getDistance()
                && race.getAge().equals(bestTime.getAge())
                && race.getStroke().equals(bestTime.getStroke());
    }

}
