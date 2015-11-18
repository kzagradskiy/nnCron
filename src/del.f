\ �������� ��� ������������
\ ���������� � 'crontab.f'

REQUIRE MAKE-BAK ~nemnick\lib\bak.f
0 VALUE CRON-DEL-NEW-FILE
0 VALUE TASK-FOUND?
0 VALUE DEL-RES

\ ������� ����� �������� ���-�� � CUR-NODE (value)

: CRON-NEED-DELETE? ( -- ?) CF-NODEL? 0=  CF-ONCE? AND ;

: COPY-LINE-TO-NEW-FILE TIB #TIB @ CRON-DEL-NEW-FILE WRITE-LINE DROP ;

: ?COMMENT
    HERE 1+ C@ [CHAR] # =
    IF 1 WORD DROP THEN
;

: IS-BEG-TASK?
    BEGIN BL WORD COUNT ?DUP WHILE
        S" #(" COMPARE 0=
        IF BL WORD COUNT
            CUR-NODE CRON-NAME @ COUNT COMPARE 0= EXIT
        ELSE
            ?COMMENT
        THEN
    REPEAT
    DROP FALSE
;

: IS-END-TASK?
    BEGIN BL WORD COUNT ?DUP WHILE
        S" )#" COMPARE 0= IF TRUE EXIT THEN
        ?COMMENT
    REPEAT
    DROP FALSE
;

: CRON-DELETE-PREFIX
    TASK-FOUND?
    IF
        IS-END-TASK?
        IF
            FALSE TO TASK-FOUND?
        THEN  
    ELSE
        IS-BEG-TASK?
        IF
            TRUE TO TASK-FOUND?
        ELSE
            COPY-LINE-TO-NEW-FILE
        THEN
    THEN
    1 WORD DROP
;

: LOG-DEL ( # -- )
    TO DEL-RES S" Deleting ERROR # %DEL-RES S>D <# #S #>%"
    CUR-NODE LOG-NODE
;

: CRON-DELETE
    S" Delete task: " CUR-NODE LOG-NODE
    CUR-NODE CRON-FILENAME @ COUNT MAKE-BAK ?DUP
        IF LOG-DEL EXIT THEN 
    CUR-NODE CRON-FILENAME @ COUNT W/O CREATE-FILE ?DUP
        IF LOG-DEL DROP EXIT THEN 
        TO CRON-DEL-NEW-FILE
    FALSE TO TASK-FOUND?
    ['] CRON-DELETE-PREFIX TO <PRE>
    CUR-NODE CRON-FILENAME @ COUNT MAKE-BAK-PATH ['] INCLUDED CATCH ?DUP
                    IF LOG-DEL 2DROP THEN
    ['] NOOP TO <PRE>
    CRON-DEL-NEW-FILE CLOSE-FILE DROP
;

: ?CRON-DELETE CRON-NEED-DELETE? IF CRON-DELETE THEN ;