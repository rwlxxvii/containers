rule APT29_GraphicalProton {
    meta:
        description = "AA23-347A Russian Foreign Intelligence Service (SVR) Exploiting JetBrains TeamCity CVE Globally"
        author = "CISA"
        reference = "https://www.cisa.gov/news-events/cybersecurity-advisories/aa23-347a"
        date = "2023-12-13"
    strings:
        // C1 E9 1B                                shr     ecx, 1Bh
        // 48 8B 44 24 08                          mov     rax, [rsp+30h+var_28]
        // 8B 50 04                                mov     edx, [rax+4]
        // C1 E2 05                                shl     edx, 5
        // 09 D1                                   or      ecx, edx
        // 48 8B 44 24 08                          mov     rax, [rsp+30h+var_28]
        $op_string_crypt = { c1 e? (1b | 18 | 10 | 13 | 19 | 10) 48 [4] 8b [2] c1 e? (05 | 08 | 10 | 0d | 07) 09 ?? 48 }

        // 48 05 20 00 00 00                       add     rax, 20h ; ' '
        // 48 89 C1                                mov     rcx, rax
        // 48 8D 15 0A A6 0D 00                    lea     rdx, unk_14011E546
        // 41 B8 30 00 00 00                       mov     r8d, 30h ; '0'
        // E8 69 B5 FE FF                          call    sub_14002F4B0
        // 48 8B 44 24 30                          mov     rax, [rsp+88h+var_58]
        // 48 05 40 00 00 00                       add     rax, 40h ; '@'
        // 48 89 C1                                mov     rcx, rax
        // 48 8D 15 1B A6 0D 00                    lea     rdx, unk_14011E577
        // 41 B8 70 01 00 00                       mov     r8d, 170h
        // E8 49 B5 FE FF                          call    sub_14002F4B0
        // 48 8B 44 24 30                          mov     rax, [rsp+88h+var_58]
        // 48 05 60 00 00 00                       add     rax, 60h ; '`'
        // 48 89 C1                                mov     rcx, rax
        // 48 8D 15 6C A7 0D 00                    lea     rdx, unk_14011E6E8
        // 41 B8 2F 00 00 00                       mov     r8d, 2Fh ; '/'
        // E8 29 B5 FE FF                          call    sub_14002F4B0
        // 48 8B 44 24 30                          mov     rax, [rsp+88h+var_58]
        // 48 05 80 00 00 00                       add     rax, 80h
        // 48 89 C1                                mov     rcx, rax
        // 48 8D 15 7C A7 0D 00                    lea     rdx, unk_14011E718
        // 41 B8 2F 00 00 00                       mov     r8d, 2Fh ; '/'
        // E8 09 B5 FE FF                          call    sub_14002F4B0
        // 48 8B 44 24 30                          mov     rax, [rsp+88h+var_58]
        // 48 05 A0 00 00 00                       add     rax, 0A0h
        $op_decrypt_config = {
            48 05 20 00 00 00 48 89 C1 48 [6] 41 B8 ?? ?? 00 00 E8 [4] 48 [4]
            48 05 40 00 00 00 48 89 C1 48 [6] 41 B8 ?? ?? 00 00 E8 [4] 48 [4]
            48 05 60 00 00 00 48 89 C1 48 [6] 41 B8 ?? ?? 00 00 E8 [4] 48 [4]
            48 05 80 00 00 00 48 89 C1 48 [6] 41 B8 ?? ?? 00 00 E8 [4] 48 [4]
            48 05 A0 00 00 00
        }

    condition:
        all of them
}