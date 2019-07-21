# XRPValidator-Verified


Docker Install

sudo docker run -dit --restart always --name rippledvalidator -p 51235:51235 -v /keystore/:/keystore/ xrptipbot/rippledvalidator

Check Logs

docker logs -f rippledvalidator


Purpose: To create a Rippled Validator, Issue SSL Cert & Assign to Nginx Web Host to be verified by Rippled and be placed in the verified Validator List.

I have no original material in this script. I pieced together two scripts from these fellows below to hopefully make it a super easy step. 

Credit: https://twitter.com/baltazar223
        https://twitter.com/WietseWind

Just run the Command Below in a Digital Ocean Docker App! 

sudo wget https://raw.githubusercontent.com/MoreScheetz/XRPValidator-Verified/master/Install.sh -O install.sh && bash install.sh


The end of your script will look like this:

OK! All set! Please send the output below to Ripple.

------------------------------------------------------

Go to:
https://docs.google.com/forms/d/e/1FAIpQLScszfq7rRLAfArSZtvitCyl-VFA9cNcdnXLFjURsdCQ3gHW7w/viewform

Domain: nick.scheetz.rocks

#1 Validator public key: nHDH8Urd2pPkL1bW5Mbkq4kUqcjX2LVpKAhMddVPti3pBYoZUuhw

#2 SSL Signature:
(stdin)= 78a30ec4b9299130771f3fa2be95ec53e025781bda93e7675e563dbb622061fd91d89b65afa368289238cd665d0517293a0a085daac5f590d67d6e065c8d3522dad965ff828ad7b561e6f3d3ec21752fa670287b948b7cbac709499f647c16d431d7aa88eaae8d75fb3a275c61919790c6a6e40631ca12101ec4ff4b7ba6e168b1498c1625d9f9d0e1c22337007c7e96062c3c88e85a3a2bfb0c6bc03b21c73656f404f85899093a9b4138042f8a12680a2684fe973f948341a57eff0354220d0caa3682d5eb14781566821a9b7fc9a08ed19f4d723a70b0e1e866cbb9c4468bcbae65575b81c4a5bf59bd12a25a17f3f0d9bec972de9f8fe6bcdf1d96f39ed0

#3 Domain signature for nick.scheetz.rocks:
471CE7C8E36627B547B86EC492D5213F0E6920D0D8CDB312D615D2FFDB127B0E3377E3727CF5EE57167D7C3CA98B8E864ECA32F5FA345AAB0F7B67D5DD3D9F0B

A Text file was also generated at /keystore/validation-data.txt with the info generated at the end of your script.
