/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.sixstreams.app.data.crawlers;

import com.iswim.loader.MeetCrawlerDriver;

/**
 *
 * @author anpwang
 */
public class CronJob {
    public static void main(String[] args)
    {
        StockCrawler.load();
        MeetCrawlerDriver.load();
    }
}
