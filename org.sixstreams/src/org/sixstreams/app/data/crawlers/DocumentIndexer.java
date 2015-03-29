package org.sixstreams.app.data.crawlers;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.codehaus.jackson.map.ObjectMapper;
import org.sixstreams.app.data.crawlers.yahoo.YahooFinance;
import org.sixstreams.app.marketIntel.Stock;
import org.sixstreams.search.IndexingException;
import org.sixstreams.search.data.PersistenceManager;

public class DocumentIndexer {

    static PersistenceManager persistenceManager = new PersistenceManager();
    static String cacheLocation = YahooFinance.CACHE_LOCATION;

    static {
        Logger.getLogger("org").setLevel(Level.SEVERE);
    }

    public static void main(String[] args) {
        long timeStarted = System.currentTimeMillis();
        DocumentIndexer indexer = new DocumentIndexer();
        indexer.index(Stock.class);
        System.err.println("Time spent indexing " + (System.currentTimeMillis() - timeStarted));
    }

    public void index(Class<?> clazz) {
        File directory = new File(cacheLocation);
        if (!directory.exists()) {
            System.err.println(directory.getAbsolutePath() + " does not exist");
            return;
        } else {
            System.err.println(directory.getAbsolutePath() + " does exist");
        }

        ObjectMapper mapper = new ObjectMapper();
        List<Object> list = new ArrayList<>();
        for (File file : directory.listFiles()) {
//			String fileName = file.getAbsolutePath() + File.separator + clazz.getName() + File.separator + YahooFinance.getDateString(new Date());

            String fileNameFromClass = clazz.getName().replace(".", "_");
            StringBuilder b = new StringBuilder(fileNameFromClass);

            b.replace(fileNameFromClass.lastIndexOf("_"), fileNameFromClass.lastIndexOf("_") + 1, ".");

            fileNameFromClass = b.toString();

            String fileName = file.getAbsolutePath() + File.separator + fileNameFromClass;
            try {
                Stock object = (Stock) mapper.readValue(new FileInputStream(fileName), clazz);
                if (list.size() > 100) {
                    persistenceManager.insert(list);
                    list = new ArrayList<>();
                } else {
                    list.add(object);
                }
            } catch (IOException | IndexingException e) {
            }
        }
        if (list.size() > 0) {
            try {
                persistenceManager.insert(list);
            } catch (Exception e) {
            }
        }
        persistenceManager.close();

    }
}
