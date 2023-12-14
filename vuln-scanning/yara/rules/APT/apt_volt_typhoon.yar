rule ShellJSP {

    meta:

        author = "Joint Cybersecurity Advisory"
        info = "People's Republic of China State-Sponsored Cyber Actor Living off the Land to Evade Detection"
        description = "https://node-security.com/posts/jsp-war-shell/"

    strings:

        $s1 = "decrypt(fpath)"
        $s2 = "decrypt(fcontext)"
        $s3 = "decrypt(commandEnc)"
        $s4 = "upload failed!"
        $s5 = "aes.encrypt(allStr)"
        $s6 = "newid"

    condition:

        filesize < 50KB and 4 of them

}

rule EncryptJSP {

    meta:

        author = "Joint Cybersecurity Advisory"
        info = "People's Republic of China State-Sponsored Cyber Actor Living off the Land to Evade Detection"
        description = "https://www.codejava.net/coding/file-encryption-and-decryption-simple-example"

    strings:
        $s1 = "AEScrypt"
        $s2 = "AES/CBC/PKCS5Padding"
        $s3 = "SecretKeySpec"
        $s4 = "FileOutputStream"
        $s5 = "getParameter"
        $s6 = "new ProcessBuilder"
        $s7 = "new BufferedReader"
        $s8 = "readLine()"

    condition:

        filesize < 50KB and 6 of them

}

rule CustomFRPClient {

    meta:

        author = "Joint Cybersecurity Advisory"
        info = "People's Republic of China State-Sponsored Cyber Actor Living off the Land to Evade Detection"
        description = ”Identify instances of the actor's custom FRP tool based on unique strings chosen by the actor and included in the tool”
        reference = "https://github.com/fatedier/frp"

   strings:

        $s1 = "%!PS-Adobe-" nocase ascii wide
        $s2 = "github.com/fatedier/frp/cmd/frpc" nocase ascii wide
        $s3 = "github.com/fatedier/frp/cmd/frpc/sub.startService" nocase ascii wide
        $s4 = "MAGA2024!!!" nocase ascii wide
        $s5 = "HTTP_PROXYHost: %s" nocase ascii wide

   condition:

        all of them

}

rule HACKTOOL_FRPClient {

    meta:

        author = "Joint Cybersecurity Advisory"
        info = "People's Republic of China State-Sponsored Cyber Actor Living off the Land to Evade Detection"
        description = ”Identify instances of FRP tool (Note: This tool is known to be used by multiple actors, so hits would not necessarily imply activity by the specific actor described in this report)”
        reference = "https://github.com/fatedier/frp"
        
   strings:

        $s1 = "%!PS-Adobe-" nocase ascii wide
        $s2 = "github.com/fatedier/frp/cmd/frpc" nocase ascii wide
        $s3 = "github.com/fatedier/frp/cmd/frpc/sub.startService" nocase ascii wide
        $s4 = "HTTP_PROXYHost: %s" nocase ascii wide

   condition:

        3 of them

}