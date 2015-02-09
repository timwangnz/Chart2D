package com.iswim.loader;

import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.sixstreams.search.SearchException;
import org.sixstreams.search.SearchHits;
import org.sixstreams.search.data.PersistenceManager;

import com.iswim.model.BestTime;
import com.iswim.model.MeetFile;
import com.iswim.model.Race;
import com.iswim.model.Swimmer;
import com.iswim.model.Team;

public class MeetCrawlerTest {

    static {
        Logger.getLogger("").setLevel(Level.SEVERE);
    }

    //before running this, check MeetCrawler.java line 119
    static String[] meetPages = new String[]{
        // "11results.html",
        //	 "12results.html",
        "2014"
	// "10results.html",
    // "09results.html",
    // "08results.html",
    // "07results.html",
    // "06results.html",
    // "05results.html",
    // "04results.html",
    // "03results.html",
    // "02results.html",
    };

    static String rootUrl = "http://www.pacswim.org/swim-meet-results?year=";
    static String fileUrl = "file:///Users/anpwang";

    public static void main(String[] args) {
        try {
            download(1000);
            //crawl(100000);
            System.exit(0);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void crawl(int max) {
        MeetCrawler crawler = new MeetCrawler();
        crawler.crawl(fileUrl, new String[]{
            "pacmeets"
        }, max);
    }

    public static void download(int max) {
        MeetCrawler crawler = new MeetCrawler();
        crawler.location = "/Users/anpwang/pacmeets/";
        crawler.download = true;
        crawler.crawl(rootUrl, meetPages, max);
    }

    public static void query() throws Exception {
        PersistenceManager pm = new PersistenceManager();
        SearchHits hits = pm.search("*", Race.class);
        System.err.println(hits.getHitsMetaData().getHits());

        hits = pm.search("*", BestTime.class);
        System.err.println(hits.getHitsMetaData().getHits());

        hits = pm.search("*", Swimmer.class);
        System.err.println(hits.getHitsMetaData().getHits());

        hits = pm.search("*", MeetFile.class);
        System.err.println(hits.getHitsMetaData().getHits());

        hits = pm.search("*", Team.class);
        System.err.println(hits.getHitsMetaData().getHits());

        for (Object race : pm.query("*", Race.class)) {
            System.err.println(race);
        }

        System.err.println("---------------------");

        for (Object race : pm.query("*", MeetFile.class)) {
            System.err.println(((MeetFile) race).getName());
        }

        long startedAt = System.currentTimeMillis();
        System.err.println("---------------------");
        Map<String, Object> filters = new HashMap<String, Object>();
        filters.put("firstName", "Sarah");
        filters.put("lastName", "Wang");
        for (Object race : pm.query(filters, Race.class)) {
            System.err.println(race);
        }
        System.err.println("Time spent " + (System.currentTimeMillis() - startedAt));

        startedAt = System.currentTimeMillis();
        System.err.println("---------------------");
        filters = new HashMap<String, Object>();
        for (Object race : pm.query(filters, BestTime.class)) {
            System.err.println(race);
        }
        System.err.println("Time spent " + (System.currentTimeMillis() - startedAt));

        startedAt = System.currentTimeMillis();
        System.err.println("---------------------");
        filters.put("firstName", "Sarah");
        filters.put("lastName", "Wang");
        for (Object race : pm.query(filters, BestTime.class)) {
            System.err.println(race);
        }
        System.err.println("Time spent " + (System.currentTimeMillis() - startedAt));

        startedAt = System.currentTimeMillis();
        System.err.println("---------------------");
        filters.put("firstName", "Sarah");
        filters.put("lastName", "Wang");
        for (Object race : pm.query(filters, Race.class)) {
            System.err.println(race);
        }
        System.err.println("Time spent " + (System.currentTimeMillis() - startedAt));

    }

    public static void updateBest() {
        PersistenceManager pm = new PersistenceManager();
        try {
            SearchHits hits = pm.search("*", Swimmer.class);
            while (hits.getCount() > 0) {
				//for each stroke
                //	distance
                //  age group
                //  course
                //
            }
        } catch (SearchException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

    }

}
