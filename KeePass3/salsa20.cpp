#include "salsa20.h"

#include "/home/dan/KeePass3/KeePass3/cryptopp/modes.h"
#include "/home/dan/KeePass3/KeePass3/cryptopp/salsa.h"
#include "/home/dan/KeePass3/KeePass3/cryptopp/osrng.h"

using namespace std;

vector<char> m_xpbKey;
char* m_IV;

Salsa20::Salsa20(vector<char> pbKey, char* pbIv)
{
    m_xpbKey = pbKey;
    m_IV = pbIv;
}

byte* Salsa20::decrypt(vector<char> cipherText)
{
    byte key[32], iv[8];
    byte* cipherTextBytes = new byte[cipherText.size()];
    byte* plainTextBytes = new byte[cipherText.size()];
    string retVal("");

    for(int i=0;i<32;i++) {
        key[i] = m_xpbKey[i];
    }

    for(int i=0;i<8;i++) {
        iv[i] = m_IV[i];
    }

    for(int i=0;i<cipherText.size();i++) {
        cipherTextBytes[i] = cipherText[i];
    }

    CryptoPP::Salsa20::Encryption salsa;
    salsa.SetKeyWithIV(key, 32, iv);

    salsa.ProcessData(plainTextBytes, cipherTextBytes, cipherText.size());
    //retVal.assign((char *)plainTextBytes);

    //delete plainTextBytes;
    delete cipherTextBytes;

    return plainTextBytes;

    //return retVal;
}

