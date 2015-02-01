package org.sixstreams.app.test;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.sixstreams.search.data.PersistenceManager;
import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.data.java.annotations.SearchableAttribute;
import org.sixstreams.social.Socialable;

import com.google.gson.Gson;

@Searchable(title = "word", isSecure = false)
public class SatWord extends Socialable
{
	// @SearchableAttribute(isKey = true)
	String word;
	int knownBy;
	String meaning;
	String type;
	String sample;
	String firstLetter;
	float diffculty;
	
	String status;
	int voted;
	@SearchableAttribute(isIndexed = false)
	String synonymProvider;

	List<String> synonyms;
	List<String> relatedWords;

	public List<String> getRelatedWords()
	{
		return relatedWords;
	}

	public void setRelatedWords(List<String> relatedWords)
	{
		this.relatedWords = relatedWords;
	}

	public SatWord()
	{
		super();
	}

	public String toString()
	{
		return word + " " + meaning + " " + type + " " + sample;
	}

	SatWord(String word, String meaning, String type, String sample)
	{
		this.meaning = meaning;
		this.type = type;
		if (sample != null)
		{
			sample = sample.trim();
			if (sample.startsWith("\"") && sample.length() > 2)
			{

				sample = sample.substring(1, sample.length() - 1);
			}
		}
		this.sample = sample;
		this.setWord(word);
	}

	public static void main(String[] args)
	{
		//loadHotAndFreq();
		loadText();
	}

	static Map<String, Integer> wordCount = new HashMap<String, Integer>();

	static List stopwords = Arrays.asList(new String[]
	{
					"or", "and", "with", "a", "in", "on", "the", "he", "her", "we", "our", "an", "-", "1", "2", "3", "4", "5", "6", "7", "8", "9", "i", "which", "this", "that", "n", "said", "go",
					"by", "as", "at", "of", "has", "have", "than", "every", "some", "(a", "is", "it", "are", "etc", "for", "two", "going", "six", "been", "all", "four", "its", "upon", "makes", "no",
					"yes", "using", "over", "one's", "off", "take", "will", "may", "much", "such", "his", "their", "do", "be", "ect.", "into", "when", "what", "taken", "those", "where", "not",
					"between", "out", "whom"
	});

	static void countWords(String sentence)
	{
		String[] elements = sentence.split(" ");
		for (String element : elements)
		{

			element = element.toLowerCase();

			if (element.endsWith(".") || element.endsWith(",") || element.endsWith(";") || element.endsWith("&"))
			{
				element = element.substring(0, element.length() - 1);
			}

			element = element.trim();
			if (element.length() == 0)
			{
				continue;
			}

			if (stopwords.contains(element))
			{
				continue;
			}

			Integer count = wordCount.get(element);

			if (count == null)
			{
				wordCount.put(element, new Integer(1));
			}
			else
			{
				wordCount.put(element, count + 1);
			}
		}
	}

	static Map <String,String> hot = new HashMap<String,String>();
	static Map <String,String> freq = new HashMap<String,String>();
	
	public static void loadHotAndFreq()
	{
		freq = loadWords("./highfreq.txt");
		hot = loadWords("./hotprospects.txt");
		
		System.err.println(freq);
		System.err.println(hot);
	}
	public static Map<String,String> loadWords(String name)
	{

		BufferedReader br = null;
		String sCurrentLine;
		try
		{
			InputStream inputStream = SatWord.class.getResourceAsStream(name);
			br = new BufferedReader(new InputStreamReader(inputStream, "UTF-8"));

			Map<String,String> words = new HashMap<String,String> ();

			while ((sCurrentLine = br.readLine()) != null)
			{
				
				String[] wordArray = sCurrentLine.split(",");
				for(String word : wordArray)
				{
					words.put(word,word);
				}
			}
			return words;
		}
		catch (Exception e)
		{
			return new HashMap<String,String> ();
		}
	}

	public static void loadText()
	{
		loadHotAndFreq();
		BufferedReader br = null;
		int numberOfHot = 0;
		int numberOfFreq = 0;
		try
		{
			String sCurrentLine;

			InputStream inputStream = SatWord.class.getResourceAsStream("./5000satwords.txt");
			br = new BufferedReader(new InputStreamReader(inputStream, "UTF-8"));

			List<SatWord> words = new ArrayList<SatWord>();
		  
			while ((sCurrentLine = br.readLine()) != null)
			{
				
				String[] elements = sCurrentLine.split(" ", 3);
				if (elements.length < 3)
				{
					System.err.println(sCurrentLine);
					continue;
				}
				countWords(elements[2]);
				SatWord word = new SatWord(elements[0], elements[2], elements[1], null);
				words.add(word);
			}
			
			PersistenceManager pm = new PersistenceManager();
			
			for (SatWord word : words)
			{
				word.setDateCreated(new Date());
				word.setCreatedBy("seed");
				if (hot.get(word.getWord().toLowerCase())!=null)
				{
					numberOfHot ++;
					hot.put(word.getWord().toLowerCase(), "matched");
					word.setStatus("Hot");
				}
				if (freq.get(word.getWord().toLowerCase())!=null)
				{
					numberOfFreq ++;
					freq.put(word.getWord().toLowerCase(), "matched");
					word.setStatus("High");
				}
			}
			pm.insert(words);
			/*
			// System.err.println(wordCount.size() + "\n " + wordCount);
			int counts = 0;
			for (String word : wordCount.keySet())
			{
				Integer count = wordCount.get(word);
				if (count > 5)
				{
					System.err.print(word + ",");
					counts++;
				}
			}
			
			
			System.err.println("" + counts);
			System.err.println("Hot match " + numberOfHot + " " + hot.size());
			System.err.println("Freq match " + numberOfFreq + " " + freq.size());
			List<String> missingWords = new ArrayList<String>();
			
			for (String word : hot.keySet())
			{
				String value = hot.get(word);
				if (value.equals(word))
				{
					missingWords.add(word);
				}
			}
			
			for (String word : freq.keySet())
			{
				String value = freq.get(word);
				if (value.equals(word))
				{
					missingWords.add(word);
				}
			}
			
			Collections.sort(missingWords);
			
			for (String word : missingWords)
			{
				System.err.println(word);
			}
			*/
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		finally
		{
			try
			{
				if (br != null) br.close();
			}
			catch (IOException ex)
			{
				ex.printStackTrace();
			}
		}
	}

	public static void load()
	{
		PersistenceManager pm = new PersistenceManager();
		try
		{
			Gson gson = new Gson();

			InputStream inputStream = SatWord.class.getResourceAsStream("./words.json");
			InputStreamReader isr = new InputStreamReader(inputStream);
			SatWord[] words = gson.fromJson(isr, SatWord[].class);
			for (SatWord roaster : words)
			{
				roaster.setDateCreated(new Date());
				roaster.setCreatedBy("seed");
				pm.update(roaster);
			}
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
	}

	public String getType()
	{
		return type;
	}

	public void setType(String type)
	{
		this.type = type;
	}

	public String getSample()
	{
		return sample;
	}

	public void setSample(String sample)
	{
		this.sample = sample;
	}

	public String getWord()
	{
		return word;
	}

	public void setWord(String word)
	{
		this.setId(word);
		this.firstLetter = word.substring(0, 1);
		this.word = word;
	}

	public List<String> getSynonyms()
	{
		return synonyms;
	}

	public void setSynonyms(List<String> synonyms)
	{
		this.synonyms = synonyms;
	}

	public String getMeaning()
	{
		return meaning;
	}

	public void setMeaning(String meaning)
	{
		this.meaning = meaning;
	}

	public String getSynonymProvider()
	{
		return synonymProvider;
	}

	public void setSynonymProvider(String synonymProvider)
	{
		this.synonymProvider = synonymProvider;
	}

	public String getFirstLetter()
	{
		return firstLetter;
	}

	public void setFirstLetter(String firstLetter)
	{
		this.firstLetter = firstLetter;
	}

	public int getKnownBy()
	{
		return knownBy;
	}

	public void setKnownBy(int knownBy)
	{
		this.knownBy = knownBy;
	}

	public float getDiffculty()
	{
		return diffculty;
	}

	public void setDiffculty(float diffculty)
	{
		this.diffculty = diffculty;
	}

	public int getVoted()
	{
		return voted;
	}

	public void setVoted(int voted)
	{
		this.voted = voted;
	}

	public String getStatus()
	{
		return status;
	}

	public void setStatus(String status)
	{
		this.status = status;
	}
}
