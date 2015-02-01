package org.sixstreams.search.util;

import javax.crypto.Cipher;
import javax.crypto.spec.DESKeySpec;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

public class Cryptor
{
	private Cipher deCipher;
	private Cipher enCipher;
	private SecretKeySpec key;
	private IvParameterSpec ivSpec;
	public Cryptor(String applicationKey)
	{
		if (!applicationKey.equals("public"))
		{
			
		
		ivSpec = new IvParameterSpec(applicationKey.getBytes());
		try
		{
			DESKeySpec dkey = new DESKeySpec(applicationKey.getBytes());
			key = new SecretKeySpec(dkey.getKey(), "DES");
			deCipher = Cipher.getInstance("DES/CBC/PKCS5Padding");
			enCipher = Cipher.getInstance("DES/CBC/PKCS5Padding");
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		}
	}

	public String encrypt(Object obj) throws Exception
	{
		if (enCipher == null)
		{
			return obj.toString();
		}
		
		byte[] input = convertToByteArray(obj);
		enCipher.init(Cipher.ENCRYPT_MODE, key, ivSpec);
		byte[] output = enCipher.doFinal(input);
		return new String(output);
	}

	public String decrypt(Object encrypted) throws Exception
	{
		if (deCipher == null)
		{
			return encrypted.toString();
		}
		deCipher.init(Cipher.DECRYPT_MODE, key, ivSpec);
		return convertFromByteArray(deCipher.doFinal(convertToByteArray(encrypted)));
	}

	private String convertFromByteArray(byte[] byteObject)
	{
		return new String(byteObject);
	}

	private byte[] convertToByteArray(Object complexObject)
	{
		return complexObject.toString().getBytes();
	}

}