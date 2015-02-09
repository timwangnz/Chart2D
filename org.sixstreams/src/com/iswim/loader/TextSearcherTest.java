package com.iswim.loader;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.sixstreams.rest.IdObject;
import org.sixstreams.search.IndexedDocument;
import org.sixstreams.search.SearchHits;

import com.iswim.model.BestTime;
import com.iswim.model.Race;
import com.iswim.model.Swimmer;

public class TextSearcherTest {

    static {
        Logger.getLogger("").setLevel(Level.SEVERE);
    }
    static int totalRaces = 0;

    HashMap swimmersCache = new HashMap();

    TextSearcher searcher = new TextSearcher();

    public static void main(String[] args) {
        long timestarted = System.currentTimeMillis();
        TextSearcherTest testsuit = new TextSearcherTest();
		//testsuit.testGetBestTimes("(051198SARXWA SARAH) OR 05111998");
        //testsuit.testGetRaces("*");

        Map<String, Object> swimmerIdFilter = new HashMap<String, Object>();
		//swimmerIdFilter.put("club", "PCCROW");
        //testsuit.racesAgainstSwimmer(swimmerIdFilter);
        //testsuit.racesAgainstSwimmer("051198SARXWANG");
        //testsuit.racesAgainstSwimmer("051198SARXWANG");
        //testsuit.testGetBestTimes("*");
        //042095QUE_COOP Quentin Cooper 6

        testsuit.testGetRaces("Sarah");
	//	testsuit.testGetBestRaces("051198SARXWANG");
        //testsuit.testGetRaces("112394MADMWHIT");

		//testsuit.testGetBestTimes("112394MADMWHIT");//112394MADHWHIT
		//testsuit.loadSwimmers();
        testsuit.searcher.done();
        System.err.println("Total races " + totalRaces);
        System.err.println("Total swimmers " + testsuit.swimmersCache.size());
        System.err.println("time spent - " + (System.currentTimeMillis() - timestarted));
        System.exit(0);
    }

    static abstract class Task {

        abstract void doWork(Collection<? extends IdObject> objects);
    }

    static class RaseTask extends Task {

        Swimmer swimmer;
        List<IdObject> races = new ArrayList<IdObject>();

        RaseTask(Swimmer swimmer) {
            this.swimmer = swimmer;
        }

        void doWork(Collection<? extends IdObject> races) {
            this.races.addAll(races);
            totalRaces += races.size();
        }
    }

    public void racesAgainstSwimmer(String query, Map<String, Object> filters) {
        list(query, filters, Swimmer.class, new Task() {
            void doWork(Collection<? extends IdObject> swimmers) {
                for (IdObject swimmer : swimmers) {
                    String id = swimmer.getId();
                    RaseTask task = new RaseTask((Swimmer) swimmer);
                    Map<String, Object> swimmerIdFilter = new HashMap<String, Object>();
                    swimmerIdFilter.put("swimmerUSSNo", id);
                    list(id, swimmerIdFilter, Race.class, task);
                    System.err.println(swimmer.getId() + " " + ((Swimmer) swimmer).getFirstName() + " " + ((Swimmer) swimmer).getLastName() + " " + task.races.size());
                    swimmersCache.put(swimmer, task.races);
                }
            }
        }
        );
    }

    public void listAll(String query, Map<String, Object> filters, Class<? extends IdObject> clazz) {
        long timestarted = System.currentTimeMillis();
        int offset = 0;
        int limit = 100;
        while (true) {
            Collection<? extends IdObject> objects = searcher.getObjects(query, filters, clazz, offset, limit);
            if (objects.isEmpty()) {
                break;
            }
            System.err.println("number items revevied " + objects.size());
            offset += limit;
        }
        System.err.println("time spent - " + (System.currentTimeMillis() - timestarted));
    }

    public void list(String query, Map<String, Object> filters, Class<? extends IdObject> clazz, Task task) {
        long timestarted = System.currentTimeMillis();
        int offset = 0;
        int limit = 100;

        while (true) {
            Collection<? extends IdObject> objects = searcher.getObjects(query, filters, clazz, offset, limit);
            if (objects.isEmpty()) {
                break;
            }
            task.doWork(objects);
            offset += limit;
        }
        System.err.println("time spent - " + (System.currentTimeMillis() - timestarted));
    }

    public void testGetBestTimes(String query) {

        List<BestTime> races = searcher.getBestTimesForSwimmer(query);
        //System.err.println(races.getHitsMetaData().getHits());
        for (BestTime document : races) {
            System.err.println(document);
        }
    }

    public void testGetRaces(String query) {
        for (Object object : searcher.getObjects(query, Race.class, 0, 10000)) {
            System.err.println(object);
        }
    }

    public void testGetBestRaces(String query) {

        Map<String, Race> besttimes = new HashMap<String, Race>();

        for (Race race : searcher.getObjects(query, Race.class, 0, 10000)) {
            String key = race.getAge() + "," + race.getCourse() + "," + race.getStroke() + "," + race.getDistance();
            Race value = besttimes.get(key);
            if (value == null || value.getTime() > race.getTime()) {
                besttimes.put(key, race);
            }
        }
    }

    public void loadSwimmers() {
        int offset = 0;
        int limit = 100;
        long i = 0;
        HashMap<String, IndexedDocument> swimmers = new HashMap<String, IndexedDocument>();
        HashMap<String, List<IndexedDocument>> duplicates = new HashMap<String, List<IndexedDocument>>();
        while (true) {
            SearchHits meets = searcher.getSwimmers("*", offset, limit);
            //System.err.println(meets.getHitsMetaData().getHits());
            if (meets.getCount() == 0) {
                break;
            }

            for (IndexedDocument document : meets.getIndexedDocuments()) {
                String key = ""
                        //  document.getAttrValue("firstName")  +  " " 
                        //+ document.getAttrValue("middleName") + " "
                        //	+ document.getAttrValue("lastName")  +  " "
                        + document.getAttrValue("dateOfBirth");

                key = key.toUpperCase();
                IndexedDocument doc = swimmers.get(key);
                if (doc == null) {
                    swimmers.put(key, document);
                } else {
                    List<IndexedDocument> dup = duplicates.get(key);
                    if (dup == null) {
                        dup = new ArrayList<IndexedDocument>();
                        dup.add(doc);
                        duplicates.put(key, dup);
                    }
                    dup.add(document);
                }
                i++;
            }
            System.err.println(" " + i);
            offset += limit;
        }
        dedup(duplicates);
        System.err.println(" " + i + " " + swimmers.size());
        System.err.println(" " + i + " " + duplicates.size());
    }

    public void dedup(HashMap<String, List<IndexedDocument>> duplicates) {
        for (String key : duplicates.keySet()) {
            System.err.println(key + " " + duplicates.get(key).size());
            for (IndexedDocument doc : duplicates.get(key)) {
                System.err.println("\t" + doc.getAttrValue("id"));
            }
        }
    }

    public void testGetSwimmers(String query) {
        SearchHits meets = searcher.getSwimmers(query, 1, 10);
        System.err.println(meets.getHitsMetaData().getHits());
        for (IndexedDocument document : meets.getIndexedDocuments()) {
            System.err.println("" + document.getAttrValue("id") + " - " + document.getAttrValue("firstName") + " " + document.getAttrValue("middleName") + " " + document.getAttrValue("lastName"));
        }
    }

    public void testGetMeets(String query) {
        SearchHits meets = searcher.getMeets(query, 1, 200);
        System.err.println(meets.getHitsMetaData().getHits());
        for (IndexedDocument document : meets.getIndexedDocuments()) {
            System.err.println("" + document.getAttrValue("uniqueName") + " - " + document.getAttrValue("startDate") + " " + document.getAttrValue("hostName"));
        }
    }

    public void testGetMeets() {
        long timestarted = System.currentTimeMillis();
        testGetMeets("*");
        System.err.println("time spent - " + (System.currentTimeMillis() - timestarted));
        testGetMeets("paas");
        System.err.println("time spent - " + (System.currentTimeMillis() - timestarted));
        testGetMeets("daca");
        System.err.println("time spent - " + (System.currentTimeMillis() - timestarted));
    }

    public void testGetRace() {
        Map<String, Object> filters = new HashMap<String, Object>();
        filters.put("stroke", "Fly");
        filters.put("distance", 100);
        filters.put("age", "1516");
        filters.put("gender", "M");

        SearchHits races = searcher.getMeetRaces("2012 PC SSF  SCY PC-C/B/A+", filters, 1, 10);
        System.err.println(races.getHitsMetaData().getHits());

        for (IndexedDocument document : races.getIndexedDocuments()) {
            System.err.println(document.getContent());
        }
    }
}
