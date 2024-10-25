FUNCTION-POOL zbc_transport_bte.            "MESSAGE-ID ..

* INCLUDE LZBC_TRANSPORT_BTED...             " Local class definition
************************************************************************
* type pools from DDIC
************************************************************************
TYPE-POOLS: sabc.
INCLUDE scms_defs.

************************************************************************
* include all necessary global data
************************************************************************

* OK-Code definition
DATA: iv_okcode TYPE sy-ucomm.

* Possible objects (dialog subscreens) for Ok-Codes
CONSTANTS: BEGIN OF ic_okcode_object,
             source      LIKE iv_okcode VALUE 'SRC_',
             rel         LIKE iv_okcode VALUE 'REL_',
             usage_vacl  LIKE iv_okcode VALUE 'USG_',
             usage_rvl   LIKE iv_okcode VALUE 'US2_',
             freetxt     LIKE iv_okcode VALUE 'FRE_',
             valuation   LIKE iv_okcode VALUE 'VAL_',
             components  LIKE iv_okcode VALUE 'CMP_',
             cl_transp   LIKE iv_okcode VALUE 'TCL_',
             cl_hazinds  LIKE iv_okcode VALUE 'TCL_',
             danger_clss LIKE iv_okcode VALUE 'DGL_',
             pckngc_lcns LIKE iv_okcode VALUE 'DGL_',
             transp_lcns LIKE iv_okcode VALUE 'DGL_',
             templ_ident LIKE iv_okcode VALUE 'tid_',
             templ_usage LIKE iv_okcode VALUE 'tus_',
             target      LIKE iv_okcode VALUE 'trg_',
           END OF ic_okcode_object.

* Possible OK-Codes
DATA: BEGIN OF ic_okvalue,
        nop             LIKE iv_okcode VALUE 'NOP ', "no operation
        list_refresh    LIKE iv_okcode VALUE '__LR',  " list refresh
*-----------------------------------------------------------------------
*       Symbole - symbols (Kürzel P for PUBLIC)
*-----------------------------------------------------------------------
        phlp            LIKE iv_okcode VALUE 'PHLP', "Hilfe         - help
        pval            LIKE iv_okcode VALUE 'PVAL', "Eingabemögl.  - list of val.
*       Bei den Scroll-Funktionen wurden die Codes verändert,
*       da die Funktion SCROLLING_IN_TABLE eingebunden wird.
        pfst            LIKE iv_okcode VALUE 'P--' , "Erste Seite   - first page
        pprv            LIKE iv_okcode VALUE 'P-'  , "Vorige Seite  - prev. page
        pnxt            LIKE iv_okcode VALUE 'P+'  , "Nächste Seite - next page
        plst            LIKE iv_okcode VALUE 'P++' , "Letzte Seite  - last page
*       for buttons to scroll in step-loop #1
        l1fs            LIKE iv_okcode VALUE 'L1--', "Erste Seite   - first page
        l1pr            LIKE iv_okcode VALUE 'L1-' , "Vorige Seite  - prev. page
        l1nx            LIKE iv_okcode VALUE 'L1+' , "Nächste Seite - next page
        l1ls            LIKE iv_okcode VALUE 'L1++', "Letzte Seite  - last page
*       for buttons to scroll in step-loop #2
        l2fs            LIKE iv_okcode VALUE 'L2--', "Erste Seite   - first page
        l2pr            LIKE iv_okcode VALUE 'L2-' , "Vorige Seite  - prev. page
        l2nx            LIKE iv_okcode VALUE 'L2+' , "Nächste Seite - next page
        l2ls            LIKE iv_okcode VALUE 'L2++', "Letzte Seite  - last page
*       for buttons in dynpros
        bprev           LIKE iv_okcode VALUE 'BPVA', " previous value button
        bnext           LIKE iv_okcode VALUE 'BNVA', " next value button
        bcus            LIKE iv_okcode VALUE 'BCUS', " customer button
        boff            LIKE iv_okcode VALUE 'BOFF', " office user button
        brec            LIKE iv_okcode VALUE 'BREC', " sds-receiver button
        bimm            LIKE iv_okcode VALUE 'BIMM', " button immediately
        bbck            LIKE iv_okcode VALUE 'BBCK', " button in background task
        bspp            LIKE iv_okcode VALUE 'BSPP', " set print parameters
        bsta            LIKE iv_okcode VALUE 'STAT', " status button
        bf4t            LIKE iv_okcode VALUE 'F4TR', " F4-property-tree button
        bsel            LIKE iv_okcode VALUE 'BSEL', " selection-button
        bsup            LIKE iv_okcode VALUE 'BSUP', " sort ascending-button
        bsdn            LIKE iv_okcode VALUE 'BSDN', " sort descending-button
        bsal            LIKE iv_okcode VALUE 'BSAL', " select all button
        bdsal           LIKE iv_okcode VALUE 'BDAL', " deselect all button
        bdel            LIKE iv_okcode VALUE 'BDEL', " delete button
        bent            LIKE iv_okcode VALUE 'BENT', " enter button
        bcan            LIKE iv_okcode VALUE 'BCAN', " cancle button

*       for buttons in table controls / step loops
*       ATTENTION: Reserved name space: '_001' ... '_999' !!
        button001       LIKE iv_okcode VALUE '_001', " button in line 1
        button899       LIKE iv_okcode VALUE '_899', " button in line 899
        button999       LIKE iv_okcode VALUE '_999', " button in line 999
        button001_left  LIKE iv_okcode VALUE 'L001',
        " left button in line 001
        button999_left  LIKE iv_okcode VALUE 'L999',
        " left button in line 999
        button001_right LIKE iv_okcode VALUE 'R001',
        " right button in line 001
        button999_right LIKE iv_okcode VALUE 'R999',
        " right button in line 999

        pret            LIKE iv_okcode VALUE ' '   , "ENTER        - return
        pexe            LIKE iv_okcode VALUE 'PEXE', "Ausführen    - execute

*-----------------------------------------------------------------------
*       Objekt - object (Kürzel O)
*-----------------------------------------------------------------------
        oupd            LIKE iv_okcode VALUE 'OUPD', "Ändern        - change/upd.
        ocha            LIKE iv_okcode VALUE 'OCHA', "Anderes Objekt- change obj.
        ocre            LIKE iv_okcode VALUE 'OCRE', "Anlegen       - create
        odis            LIKE iv_okcode VALUE 'ODIS', "Anzeigen      - display
        ochm            LIKE iv_okcode VALUE 'OCHM', "Anz.<->Änd.   - change mode
        oend            LIKE iv_okcode VALUE 'OEND', "Beenden       - exit
        opst            LIKE iv_okcode VALUE 'OPST', "Buchen        - post
        oprn            LIKE iv_okcode VALUE 'OPRN', "Drucken       - print
        ogen            LIKE iv_okcode VALUE 'OGEN', "Generieren    - generate
        open            LIKE iv_okcode VALUE 'OPEN', "Holen         - open
        odel            LIKE iv_okcode VALUE 'ODEL', "Löschen       - delete
        ohld            LIKE iv_okcode VALUE 'OHLD', "Merken        - hold
        osav            LIKE iv_okcode VALUE 'OSAV', "Sichern       - save
        ocop            LIKE iv_okcode VALUE 'OCOP', "Vorlage kopie.- copy from
        otst            LIKE iv_okcode VALUE 'OTST', "(Einzel-)Test - test
        oreq            LIKE iv_okcode VALUE 'OREQ', "Anfordern     - request
        oddi            LIKE iv_okcode VALUE 'ODDI', "Direkt anzeig - direct view
        odpr            LIKE iv_okcode VALUE 'ODPR', "Direkt drucken- direct print
        ocrb            LIKE iv_okcode VALUE 'OCRB', "Rohb anl Batch- create raw rep
        ocri            LIKE iv_okcode VALUE 'OCRI', "Rohb anl sofor- create raw rep
        oprp            LIKE iv_okcode VALUE 'OPRP', "Rohber anz/dru- print raw rep
        oprc            LIKE iv_okcode VALUE 'OPRC', "Rohber anlegen- create raw rep
        opel            LIKE iv_okcode VALUE 'OPEL', "Bericht Vorl. - rep layout pr
        oper            LIKE iv_okcode VALUE 'OPER', "Bericht Rohb. - rep rawrep pr
        oprd            LIKE iv_okcode VALUE 'OPRD', "Berichtsverand- report distr
        ofre            LIKE iv_okcode VALUE 'OFRE', "Berichts freig- report free
        ores            LIKE iv_okcode VALUE 'ORES', "Berichts rücks- report reset
        orrs            LIKE iv_okcode VALUE 'ORRS', "Rohber. Status- rawrep stat.
        oacc            LIKE iv_okcode VALUE 'OACC', "Bericht annehmen- rep. accept
        oref            LIKE iv_okcode VALUE 'OREF', "Bericht ablehnen- rep. refuse
        orep            LIKE iv_okcode VALUE 'OREP', "Berichte wiederh- rep. repeat
        over            LIKE iv_okcode VALUE 'OVER', "Berichte vers.-   rep. vers.
        ohis            LIKE iv_okcode VALUE 'OHIS', "Berichte hist.-   rep. hist.
        oexp            LIKE iv_okcode VALUE 'OEXP', "Exportieren   - export
        oale            LIKE iv_okcode VALUE 'OALE', "ALE-Verteilung man.- ALE send
        oald            LIKE iv_okcode VALUE 'OALD', "ALE-Verteilung-mod.- ALE send
        odif            LIKE iv_okcode VALUE 'ODIF', "Unterschiede  - diference
*       oovc LIKE ig_okcode VALUE 'OOVC', "output variant config.
*       oovw LIKE ig_okcode VALUE 'OOVW', "output variant change
        ohsh            LIKE iv_okcode VALUE 'OHSH', "load hitlist
        ohsv            LIKE iv_okcode VALUE 'OHSV', "save hitlist
        oinh            LIKE iv_okcode VALUE 'OINH', "inherit from source popup
        otpd            LIKE iv_okcode VALUE 'OTPD', "display templates
        otpe            LIKE iv_okcode VALUE 'OTPE', "edit templates

*-----------------------------------------------------------------------
*       status-handling
*-----------------------------------------------------------------------
        stip            LIKE iv_okcode VALUE 'STIP', " to 'in progress'
        stns            LIKE iv_okcode VALUE 'STNS', " to 'next status'
        sttr            LIKE iv_okcode VALUE 'STTR', " to 'to release'
        stnc            LIKE iv_okcode VALUE 'STNC', " to 'noncritical change'
        stre            LIKE iv_okcode VALUE 'STRE', " to 'released'

*-----------------------------------------------------------------------
*       Bearbeiten - edit (KÜRZEL E)
*-----------------------------------------------------------------------
*       --- special select-codes for the query maintenance ---
        oqsh            LIKE iv_okcode VALUE 'OQSH', "load query
        equs            LIKE iv_okcode VALUE 'EQUS', "use query
        eqst            LIKE iv_okcode VALUE 'EQST', "query step
        eqcp            LIKE iv_okcode VALUE 'EQCP', "query copy
        eqrf            LIKE iv_okcode VALUE 'EQRF', "query reference
        eqsm            LIKE iv_okcode VALUE 'EQSM', "simulate query execution
*       --------------------------------------------------
        eslc            LIKE iv_okcode VALUE 'ESLC', "Markieren(F9) - select entry
        esal            LIKE iv_okcode VALUE 'ESAL', "Alle markier. - select all
        esbl            LIKE iv_okcode VALUE 'ESBL', "Block mark.   - select block
        edal            LIKE iv_okcode VALUE 'EDAL', "Alle Mark lö. - deselect all
        edsl            LIKE iv_okcode VALUE 'EDSL', "Entmarkieren  - deselect entr
*       --- special select-codes for the property-tree ---
        eslt            LIKE iv_okcode VALUE 'TRMK', "Markieren(F9) - select entry
        esit            LIKE iv_okcode VALUE 'ESIT', "intern Mark.  - select int.
        esbt            LIKE iv_okcode VALUE 'TRM+', "Block mark.   - select block
        edat            LIKE iv_okcode VALUE 'MKDL', "Alle Mark lö. - deselect all
        edai            LIKE iv_okcode VALUE 'EDAI', "Mark int. lö. - des. all int.
        edsi            LIKE iv_okcode VALUE 'EDSI', "int. Entmark. - deselect int.
*       --------------------------------------------------
        enwl            LIKE iv_okcode VALUE 'ENWL', "Neue Einträge - new lines
        eapp            LIKE iv_okcode VALUE 'EAPP', "Anhängen      - append
        esel            LIKE iv_okcode VALUE 'TRSL', "Auswählen     - choose
        "Doppelklick   - double click
        trpi            LIKE iv_okcode VALUE 'TRPI', "Auswählen     - choose
        " Tree Control: Doppelklick   - double click
        lsel            LIKE iv_okcode VALUE 'PIC1', "Auswählen     - choose
        "Doppelklick   - double click
        tsel            LIKE iv_okcode VALUE 'TSEL', "Auswählen für ALV-Grid
*         (special for the use of the listtool (group C14T))
        nosp            LIKE iv_okcode VALUE 'NOSP', "search: non-empty charact.s
        eexp            LIKE iv_okcode VALUE 'TREP', "alle Kn.exp.  - exp.all nodes
        ecmp            LIKE iv_okcode VALUE 'TRCM', "alle Kn.kmp.  - cmp.all nodes
        efoc            LIKE iv_okcode VALUE 'TRZM', "Kn.-Focus     - focus node
        epos            LIKE iv_okcode VALUE 'TRTO', "positionieren - set position
        ecut            LIKE iv_okcode VALUE 'ECUT', "Ausschneiden  - cut
        epst            LIKE iv_okcode VALUE 'EPST', "Einsetzen     - paste
        eins            LIKE iv_okcode VALUE 'EINS', "Einfügen      - insert
        ecop            LIKE iv_okcode VALUE 'ECOP', "Kopieren      - copy
        emve            LIKE iv_okcode VALUE 'EMVE', "Verschieben   - move
        eswp            LIKE iv_okcode VALUE 'ESWP', "Vertauschen   - swap
        eres            LIKE iv_okcode VALUE 'ERES', "Umsortieren   - re-sort
        efnd            LIKE iv_okcode VALUE 'EFND', "Suchen        - find
        efnn            LIKE iv_okcode VALUE 'EFN+', "nächsten S.   - find next
        edel            LIKE iv_okcode VALUE 'EDEL', "Löschen       - delete
        elin            LIKE iv_okcode VALUE 'ELIN', "Zeile einfügen- insert line
        elde            LIKE iv_okcode VALUE 'ELDE', "Zeile löschen - delete line
        ecm1            LIKE iv_okcode VALUE 'ECM1', "Ansicht<->Bearbeiten 8010
        ecm2            LIKE iv_okcode VALUE 'ECM2', "Ansicht<->Bearbeiten 8020
        elap            LIKE iv_okcode VALUE 'ELAP', "Zeile anfügen - append line
        ecor            LIKE iv_okcode VALUE 'ECOR', "Korrigieren   - correct
        esrt            LIKE iv_okcode VALUE 'ESRT', "Sortieren     - sort
        esru            LIKE iv_okcode VALUE 'ESRU', "Sort. Aufst.  - sort up
        esrd            LIKE iv_okcode VALUE 'ESRD', "Sort. Abst.   - sort down
        eref            LIKE iv_okcode VALUE 'EREF', "Auffrischen   - refresh
        eund            LIKE iv_okcode VALUE 'EUND', "Wiederrufen   - undo
        ecan            LIKE iv_okcode VALUE 'ECAN', "Abbrechen     - cancel
        echk            LIKE iv_okcode VALUE 'ECHK', "Prüfen Datei  - check file
        eimp            LIKE iv_okcode VALUE 'EIMP', "Importieren   - import
        eimi            LIKE iv_okcode VALUE 'EIMI', "Importieren   - import
        eexo            LIKE iv_okcode VALUE 'EEXO', "Exportieren   - export
        esen            LIKE iv_okcode VALUE 'ESEN', "Sofort vers.  - send immediat.
        edap            LIKE iv_okcode VALUE 'EDAP', "Auswählen - Ablauf-Protokoll
        ersa            LIKE iv_okcode VALUE 'ERSA', "Nachvers. akt.- activate res.
        ersd            LIKE iv_okcode VALUE 'ERSD', "N.vers. deakt.- deactivate re.
        ecpr            LIKE iv_okcode VALUE 'ECPR', "Phrasenvergl. - compare phrase
        errl            LIKE iv_okcode VALUE 'ERRL', "Rele. rücks. - reset relevancy
        esrl            LIKE iv_okcode VALUE 'ESRL', "Rele. set.   - set relevancy
        eclr            LIKE iv_okcode VALUE 'ECLR', "Zurücksetzen - clear
        eusa            LIKE iv_okcode VALUE 'EUSA', " Verwendung - edit usage
        erpl            LIKE iv_okcode VALUE 'ERPL', " Ersetzen - replace
        eina            LIKE iv_okcode VALUE 'EINA', " Vererbung aktivieren
        eind            LIKE iv_okcode VALUE 'EIND', " Vererbung deaktivieren
        exbp            LIKE iv_okcode VALUE 'EXBP',  " Vererbungsreport anstarten

        srch            LIKE iv_okcode VALUE '%SC ', "Suchen - search
        srcn            LIKE iv_okcode VALUE '%SC+', "Nächsten Suchen - search next
        soup            LIKE iv_okcode VALUE 'SOUP', "Aufsteigend S. - sort upwards
        sodn            LIKE iv_okcode VALUE 'SODN', "Absteigend S.- sort downwards

*       variable field dialog
        eoap            LIKE iv_okcode VALUE 'EOAP', "Objekt anhängen - object append
        eode            LIKE iv_okcode VALUE 'EODE', "Objekt löschen - object delete

*-----------------------------------------------------------------------
*       Springen - goto (Kürzel G)
*-----------------------------------------------------------------------
        govr            LIKE iv_okcode VALUE 'GOVR', "Übersicht     - overview
        ghea            LIKE iv_okcode VALUE 'GHEA', "Kopfbild      - header
        gial            LIKE iv_okcode VALUE 'GIAL', "Kopfbild      - header
        gidn            LIKE iv_okcode VALUE 'GIDN', "Identifikation- identification
        gmat            LIKE iv_okcode VALUE 'GMAT', "Materialzuord.- ?
        gvhe            LIKE iv_okcode VALUE 'GVHE', "Bewertungskopf- valuation head
        gval            LIKE iv_okcode VALUE 'GVAL', "Bewertung     - valuation
        gvpo            LIKE iv_okcode VALUE 'GVPO', "Bew.position  - val. position
        gcdh            LIKE iv_okcode VALUE 'GCDH', "Belegschr. Protokoll
        gcds            LIKE iv_okcode VALUE 'GCDS', "Belegschr. Protokoll
*                                          Gefahrgut - dangerous good
        gtcl            LIKE iv_okcode VALUE 'GTCL', "Transp.klass. - trans. class.
        gdl_            LIKE iv_okcode VALUE 'GDL_', "Treffer Liste - hitlist
        gdl7            LIKE iv_okcode VALUE 'GDL7', "Liste Bef.Zul.- list MOS
        gdlb            LIKE iv_okcode VALUE 'GDLB', "Liste Verpack.- list packing
        gdld            LIKE iv_okcode VALUE 'GDLD', "Liste Gef.Pot.- list dan.pot.
        gdd_            LIKE iv_okcode VALUE 'TRSL', "Detailbild GGA- detail DGP
        gdd1            LIKE iv_okcode VALUE 'GDD1', "Detailbild 1  - detail 1
        gdd2            LIKE iv_okcode VALUE 'GDD2', "Detailbild 2  - detail 2
        gdd3            LIKE iv_okcode VALUE 'GDD3', "Detailbild 3  - detail 3
        gdd4            LIKE iv_okcode VALUE 'GDD4', "Detailbild 4  - detail 4

        gopl            LIKE iv_okcode VALUE 'GOPL', "Ausgabeliste  - output list
        gpli            LIKE iv_okcode VALUE 'GPLI', "Vorige Liste  - prev. list
        gnli            LIKE iv_okcode VALUE 'GNLI', "Nächste Liste - next list
        gppr            LIKE iv_okcode VALUE 'GPPR', "Vorige Eigens.- prev. property
        gnpr            LIKE iv_okcode VALUE 'GNPR', "Nächste Eigens- next property
        gpen            LIKE iv_okcode VALUE 'GPEN', "Voriger Eintr.- prev. entry
        gnen            LIKE iv_okcode VALUE 'GNEN', "Nächster Eintr- next entry

        grsl            LIKE iv_okcode VALUE 'GRSL', "Trefferliste  - result list
        srsl            LIKE iv_okcode VALUE 'SRSL', "Trefferliste  - simple list
        gpob            LIKE iv_okcode VALUE 'GPOB', "Voriges Obj. - prev. object
        gnob            LIKE iv_okcode VALUE 'GNOB', "Nächstes Obj.- next object
*       We also need a 'double jump' when we do a 'Next Substance'
*       from the property-level. then we need to go two hierarchy-levels
*       up to the hit-list and agaim two levels down to the property of
*       the next substance.
        dpob            LIKE iv_okcode VALUE 'DPOB', "prev. object - double jump
        dnob            LIKE iv_okcode VALUE 'DNOB', "next object - double jump

        gfst            LIKE iv_okcode VALUE 'GFST', "Erste Pos.    - first item
        gprv            LIKE iv_okcode VALUE 'GPRV', "Vorige Pos.   - prev. item
        gnxt            LIKE iv_okcode VALUE 'GNXT', "Nächste Pos.  - next item
        glst            LIKE iv_okcode VALUE 'GLST', "Letzte Pos.   - last item
        goth            LIKE iv_okcode VALUE 'GOTH', "Andere Posit. - other item
        gbck            LIKE iv_okcode VALUE 'GBCK', "Zurück        - back
        gphe            LIKE iv_okcode VALUE 'GPHE', "Phrasen       - phrase
        gppo            LIKE iv_okcode VALUE 'GPPO', "Phrasentext   - phrase text
        gpoh            LIKE iv_okcode VALUE 'GPOH', "Vorige Phrase - prev. phrase
        gnoh            LIKE iv_okcode VALUE 'GNOH', "Nächste Phrase- next phrase
        gspo            LIKE iv_okcode VALUE 'GSPO', "Zug. Auswahlm.- joind select.
        gscj            LIKE iv_okcode VALUE 'GSCJ', "AuswM-Merkm-Zu- sel.set-ch.tic
        gbuf            LIKE iv_okcode VALUE 'GBUF', "jump on buffer breakpoint
        glon            LIKE iv_okcode VALUE 'GLON', "Anz. Langtext - show longtext
        gftx            LIKE iv_okcode VALUE 'GFTX', " Freitexte    - free text
        gapo            LIKE iv_okcode VALUE 'GAPO', " Anw.Objekte - appl.objects

*       export/import
        gpro            LIKE iv_okcode VALUE 'GPRO', "Parser Proto. - parser proto.
        gdim            LIKE iv_okcode VALUE 'GDIM', "Direct-Input  - direct-input
        gpar            LIKE iv_okcode VALUE 'GPAR', "Import Param. - import param.
        gepr            LIKE iv_okcode VALUE 'GEPR', "Austausch-Pro.- exchang profil
        gdow            LIKE iv_okcode VALUE 'GDOW', "Datenlieferant - data distr.

*       to edit a report we need to call word on the PC
        gwup            LIKE iv_okcode VALUE 'GWUP', "Bericht editieren - edit rep.
        gwdi            LIKE iv_okcode VALUE 'GWDI', "Bericht anzeigen - show rep.
        lwdi            LIKE iv_okcode VALUE '1WDI', "Bericht anzeigen - show rep.
        gwpr            LIKE iv_okcode VALUE 'GWPR', "Bericht drucken  - print rep.
        lwpr            LIKE iv_okcode VALUE '1WPR', "Bericht drucken  - print rep.

*       report distribution
        gdal            LIKE iv_okcode VALUE 'GDAL', "Ablaufproto anz. - show actlog
        gdpv            LIKE iv_okcode VALUE 'GDPV', "Param.werte anz. - show p.val.
        grdi            LIKE iv_okcode VALUE 'GRDI', "Endberichtanzeige - show rep.

*       variable field dialog
        ghrc            LIKE iv_okcode VALUE 'GHRC', "Hierarchieinfo - hierarchy inf
        gnhl            LIKE iv_okcode VALUE 'GNHL', "Nächste Hierarchie - next hier
        gphl            LIKE iv_okcode VALUE 'GPHL', "Vorherige Hier. - previous hi.
        gfhl            LIKE iv_okcode VALUE 'GFHL', "Erste Hierarchie - first hier.
        gnho            LIKE iv_okcode VALUE 'GNHO', "Nächstes Hier.obj. - next h.o.
        gpho            LIKE iv_okcode VALUE 'GPHO', "Vorheriges H.obj. - perv. h.o.

*-----------------------------------------------------------------------
*       Zusätze - details (KÜRZEL D)
*-----------------------------------------------------------------------
        dtst            LIKE iv_okcode VALUE 'DTST', "???           - ???
        dsta            LIKE iv_okcode VALUE 'DSTA', " Status       - status
        dval            LIKE iv_okcode VALUE 'DVAL', " Beurteilung  - validation
        dvlp            LIKE iv_okcode VALUE 'DVLP', " Beurteilung Popup - rel. pop
        dsrc            LIKE iv_okcode VALUE 'DSRC', " Quelle       - source
        dscp            LIKE iv_okcode VALUE 'DSCP', " Quellen PopUp - source popup
        dreg            LIKE iv_okcode VALUE 'DREG', " Regionen     - regions
        dusg            LIKE iv_okcode VALUE 'DUSG', " Verwendung   - usage
        dhis            LIKE iv_okcode VALUE 'DHIS', " Historie      - history
        dftx            LIKE iv_okcode VALUE 'DFTX', " Freitexte    - free text
        dltx            LIKE iv_okcode VALUE 'DLTX', " Langtext     - long text
        ddoc            LIKE iv_okcode VALUE 'DDOC', " Document     - displ. doc
        dimp            LIKE iv_okcode VALUE 'DIMP', " Imp Protokoll- import protoc
        dsls            LIKE iv_okcode VALUE 'DSLS', " Stoffliste   - substance list
        dcom            LIKE iv_okcode VALUE 'DCOM', " Komponenten  - components
        dltd            LIKE iv_okcode VALUE 'DLTD', " Verbinden    - join
        dlte            LIKE iv_okcode VALUE 'DLTE', " Zusammenführen - combine
        dltf            LIKE iv_okcode VALUE 'DLTF', " Abmischen akt -
        dres            LIKE iv_okcode VALUE 'DRES', " Weitere Suchfkt. - search fkt
        dscr            LIKE iv_okcode VALUE 'DSCR', " recreate sel.set-join
        ddnv            LIKE iv_okcode VALUE 'DDNV', " Neue Vers. Dok. -new vers doc
        dqre            LIKE iv_okcode VALUE 'DQRE', " Suche verfein.- refine query
        dadi            LIKE iv_okcode VALUE 'DADI', " zus. Inform. - add. info
        dpar            LIKE iv_okcode VALUE 'DPAR', " Par-Werte - par.val.
        dpcd            LIKE iv_okcode VALUE 'DPCD', " Proto.Belegschr. - proto cd
        dcmp            LIKE iv_okcode VALUE 'DCMP', " compare reports
        dwic            LIKE iv_okcode VALUE 'DWIC', " workitem-context (val.)

*       zum testen des dialogs umrechnung masseinheiten
        duch            LIKE iv_okcode VALUE 'DUCH', " unit change dialog
*-----------------------------------------------------------------------
*       Umfeld - environment (Kürzel N)
*-----------------------------------------------------------------------
        ntst            LIKE iv_okcode VALUE 'NTST', "???           - ???
        nsrc            LIKE iv_okcode VALUE 'NSRC', " Quellenverwaltung
        nsls            LIKE iv_okcode VALUE 'NSLS', " Stofflistenverwalt.
        nusg            LIKE iv_okcode VALUE 'NUSG', " Verw.profilpflege
        nphr            LIKE iv_okcode VALUE 'NPHR', " Phrasenverwaltung
        nsse            LIKE iv_okcode VALUE 'NSSE', " Auswahlmengen
        nspg            LIKE iv_okcode VALUE 'NSPG', " Phrasengruppen
        nsub            LIKE iv_okcode VALUE 'NSUB', " Einstieg Spezifikation
        nfph            LIKE iv_okcode VALUE 'NFPH', " Erstbef. Phrasen
        nfsr            LIKE iv_okcode VALUE 'NFSR', " Erstbef. Quellen
        nfsu            LIKE iv_okcode VALUE 'NFSU', " Erstbef. Spezifikationsstamm
        nfpt            LIKE iv_okcode VALUE 'NFPT', " Import Eigenschaftsbaum
        nfte            LIKE iv_okcode VALUE 'NFTE', " Import Vorlage
        ndv1            LIKE iv_okcode VALUE 'NDV1', " DVS-System (Dok. anlegen)
        ndv2            LIKE iv_okcode VALUE 'NDV2', " DVS-System (Dok. ändern)
        ndv3            LIKE iv_okcode VALUE 'NDV3', " DVS-System (Dok. anzeigen)
        nsv1            LIKE iv_okcode VALUE 'NSV1', " Variant (change)
        nsv2            LIKE iv_okcode VALUE 'NSV2', " Variant (show)
        nrei            LIKE iv_okcode VALUE 'NREI', " Berichtsauskunft - rep inq
        npst            LIKE iv_okcode VALUE 'NPST', " voriger Schritt - prev step
        nnst            LIKE iv_okcode VALUE 'NNST', " nächst. Schritt - next step
        nwwi            LIKE iv_okcode VALUE 'NWWI', " WWI-Server
        noff            LIKE iv_okcode VALUE 'NOFF', " Büro-Ausgang - office outbox
        nofi            LIKE iv_okcode VALUE 'NOFI', " Büro-Eingang - office inbox
        nspo            LIKE iv_okcode VALUE 'NSPO', " Spoolverwaltung - spool admin
        njob            LIKE iv_okcode VALUE 'NJOB', " Job-Protokoll - job protocol
        nrjo            LIKE iv_okcode VALUE 'NRJO', " Job-Protokoll - job protocol
        nave            LIKE iv_okcode VALUE 'NAVE', " AV-Ezeug. pr. - check AV-cre.
        nav1            LIKE iv_okcode VALUE 'NAV1', " AV-Ezeug. pr. - select AV-cre
        nav2            LIKE iv_okcode VALUE 'NAV2', " AV-Ezeug. pr. - check AV-cre
        npro            LIKE iv_okcode VALUE 'NPRO', " Prozeßübers. - process overv.
        nrsp            LIKE iv_okcode VALUE 'NRSP', " Berichtsvers. - rep shipping
        ndgs            LIKE iv_okcode VALUE 'NDGS', " Gefahrgutstamm - dangerous go
        nwka            LIKE iv_okcode VALUE 'NWKA', " Arbeitsbereich - work area

*-----------------------------------------------------------------------
*       Einstellungen - settings (Kürzel S)
*-----------------------------------------------------------------------
        canl            LIKE iv_okcode VALUE 'CANL',
*      susa LIKE ig_okcode VALUE 'SUSA', "VerwNachweis: opt. setzen para
        eequ            LIKE iv_okcode VALUE 'EEQU', " Auswahl erw.  - extend query
        ssef            LIKE iv_okcode VALUE 'SSEF', " Selekt.filter - select filter
        sneg            LIKE iv_okcode VALUE 'SNEG', " Auswahl neg. - negate query
        emse            LIKE iv_okcode VALUE 'EMSE', "manual reduction
        ssfr            LIKE iv_okcode VALUE 'SSFR', " SelFil lösch. - reset sel fil
        souf            LIKE iv_okcode VALUE 'SOUF', " Ausgabefilter - output filter
        sopr            LIKE iv_okcode VALUE 'SOPR', " Ausgabeparam. - output param.
        srty            LIKE iv_okcode VALUE 'SRTY', " Berichtstyp   - report type
        spri            LIKE iv_okcode VALUE 'SPRI', " Druckopt. - print-options
        sobj            LIKE iv_okcode VALUE 'SOBJ', " Spez.Typ - specification typ

*-----------------------------------------------------------------------
*       Hilfsmittel - utilities (Kürzel H)
*-----------------------------------------------------------------------
        husa            LIKE iv_okcode VALUE 'HUSA', " Verwendungsnachweis -
        hsym            LIKE iv_okcode VALUE 'HSYM', " Symb. anzeigen - show symb.
        help            LIKE iv_okcode VALUE 'HELP', " F1-H. Bew.art - F1-h. val.k.
*         (special for the valuation-tree)
        hcst            LIKE iv_okcode VALUE 'HCST', " Status ändern  - status ch.
        hsde            LIKE iv_okcode VALUE 'HSDE', " SekDat ermitt. - sec.dat.eval
        hsdp            LIKE iv_okcode VALUE 'HSDP', " SekDat Prot. - sec.dat.pro.
        hsdc            LIKE iv_okcode VALUE 'HSDC', " SekDat überpr.- sec.dat.check
        hcdo            LIKE iv_okcode VALUE 'HCDO', " Datenlieferant- data deliv.
        orul            LIKE iv_okcode VALUE 'ORUL', " Massendatenänd. -Masschange
        orun            LIKE iv_okcode VALUE 'ORUN', " Massendatenänd. Neu
*      hsdo like ig_okcode value 'HSDO', " SekDat Dialog   -Secdata dial
*      hsdd like ig_okcode value 'HSDD', " SekDat dunkel   -Secdata dark
*      hsfs like ig_okcode value 'HSFS', " SekDat Server   -Secdata serv
*      hsfd like ig_okcode value 'HSFD', " SekDat Dialog   -Secdata dial
        hlan            LIKE iv_okcode VALUE 'HLAN', " Sprachenauswahl -lang. sel.
        hexp            LIKE iv_okcode VALUE 'HEXP', " Export-Protokoll-export prot.
        himp            LIKE iv_okcode VALUE 'HIMP', " Import-Protokoll-import prot.
        hini            LIKE iv_okcode VALUE 'HINI', " Init. ändern - change initi.
        hdfm            LIKE iv_okcode VALUE 'HDFM', " Defm. ändern - change defmat
        hclg            LIKE iv_okcode VALUE 'HCLG', " Farblegende - color legend
        hsti            LIKE iv_okcode VALUE 'HSTI', " Startzeit setzen - set time
*       hpcd like ig_okcode value 'HPCD', " Proto.Belegschr. - proto cd
        hall            LIKE iv_okcode VALUE 'HALL', " alle Spez. anz. - show all
        hsub            LIKE iv_okcode VALUE 'HSUB', " Spez. anzeigen - show subs.
        hcom            LIKE iv_okcode VALUE 'HCOM', " Komponenten anz. - show comp
        href            LIKE iv_okcode VALUE 'HREF', " Referenzen anz. - show ref.
        hres            LIKE iv_okcode VALUE 'HRES', " WWI Frontend reset
        hact            LIKE iv_okcode VALUE 'HACT', " Server aktiv. - activ. serv.
        hict            LIKE iv_okcode VALUE 'HICT', " Serv. deaktiv.-inactiv. srv.
        htst            LIKE iv_okcode VALUE 'HTST', " Server testen - check srv.
        hpid            LIKE iv_okcode VALUE 'HPID', " PhrId übern. - copy phr id
*       hpgp like ig_okcode value 'HPGP', " PhrGrp übern. - copy phr grp
        hsvw            LIKE iv_okcode VALUE 'HSVW', " Spez.sicht - substance view
        hmvw            LIKE iv_okcode VALUE 'HMVW', " Mat.Sicht - material view
        hcvw            LIKE iv_okcode VALUE 'HCVW', " change view
        glis            LIKE iv_okcode VALUE 'GLIS', " Grundliste - basic list
        hexe            LIKE iv_okcode VALUE 'HEXE', " Start - start
        hbat            LIKE iv_okcode VALUE 'HBAT', " Start Batch - start of batch
        hupr            LIKE iv_okcode VALUE 'HUPR', " MasseinhProfil - unit profil
        stus            LIKE iv_okcode VALUE 'STUS', " benutzerspez.Suchkr.sichern
        lous            LIKE iv_okcode VALUE 'LOUS', " benutzerspez.Suchkr.laden

*-----------------------------------------------------------------------
*       Pflegen - maintain (Kürzel M)
*-----------------------------------------------------------------------
        mpro            LIKE iv_okcode VALUE 'MPRO', " Default Profil - edit subs.
*-----------------------------------------------------------------------
*       Werkzeuge - tools (Kürzel T)
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------
*       Sicht - view (Kürzel V)
*-----------------------------------------------------------------------
        vstd            LIKE iv_okcode VALUE 'VSTD', " Standardliste - standardlist
        vftx            LIKE iv_okcode VALUE 'VFTX', " Langtexte     - free texts
        vhis            LIKE iv_okcode VALUE 'VHIS', " Historie      - history
        vidt            LIKE iv_okcode VALUE 'VIDT', " Toggle third identificator
        vspa            LIKE iv_okcode VALUE 'VSPA', " View search parameters
        vqmi            LIKE iv_okcode VALUE 'VQMI', " QM interface
        vtch            LIKE iv_okcode VALUE 'VTCH', " Baum wechseln - change tree
        vdtl            LIKE iv_okcode VALUE 'VDTL', " Detail-Info.  - detail-info.
        vinf            LIKE iv_okcode VALUE 'VINF', " Verw.-Info    - add.-info
        vvon            LIKE iv_okcode VALUE 'VVON', " show val.-icons
        vvof            LIKE iv_okcode VALUE 'VVOF', " turn off val.-icons
        vmor            LIKE iv_okcode VALUE 'VMOR', " new select of search-values
        vlst            LIKE iv_okcode VALUE 'VLST', " Spez.anzeige umschalten

*-----------------------------------------------------------------------
*       Workbench - workbench
*-----------------------------------------------------------------------
        wbtr            LIKE iv_okcode VALUE 'WBTR', " Baum ein/ausblenden
        trtr            LIKE iv_okcode VALUE 'TRTR', " Übernehmen zu Favoriten


*-----------------------------------------------------------------------
*       menu-exits
*-----------------------------------------------------------------------
        _mx1            LIKE iv_okcode VALUE '+MX1', " 1st menue-exit
        _mx2            LIKE iv_okcode VALUE '+MX2', " 2nd menue-exit
        _mx3            LIKE iv_okcode VALUE '+MX3', " 3rd menue-exit
        _mx4            LIKE iv_okcode VALUE '+MX4', " 4th menue-exit

*-----------------------------------------------------------------------
*       Internal
*-----------------------------------------------------------------------
        ivalfile        LIKE iv_okcode VALUE 'IVALF',  "
        iotp            LIKE iv_okcode VALUE 'IOTP',   " Parametereingabe für
        " Gruppenausgabetool WWI
        iots            LIKE iv_okcode VALUE 'IOTS',   " Output-Tool show WWI


      END OF ic_okvalue.

* Transactions
CONSTANTS: BEGIN OF ic_trcode,
*       transaction code for display of product information
             ehs_about         LIKE sy-tcode VALUE 'CGVERSION',
*       transaction codes for substance maintenance
             sm_show           LIKE sy-tcode VALUE 'CG02',
             sm_change         LIKE sy-tcode VALUE 'CG02',
*       sm_create like sy-tcode value 'CG01',
*       transaction code for substance information system
             subinfsys         LIKE sy-tcode VALUE 'CG02',
*       transaction code for substance distribution
             subdistri         LIKE sy-tcode VALUE 'CG05',
*       transactions: phrase maintenance
             pm_show           LIKE sy-tcode VALUE 'CG13',
             pm_change         LIKE sy-tcode VALUE 'CG12',
*       pm_create like sy-tcode value 'CG11',
*       transactions: phrase maintenance - customizing groups
             pm_group          LIKE sy-tcode VALUE 'CGCX',
*       transactions: selection set maintenance
             ssm_show          LIKE sy-tcode VALUE 'CG1C',
             ssm_change        LIKE sy-tcode VALUE 'CG1B',
*       ssm_create like sy-tcode value 'CG1A',
*       transactions: selection sets joined to characteristics
             ss_ch_j_show      LIKE sy-tcode VALUE 'CGAC',
             ss_ch_j_change    LIKE sy-tcode VALUE 'CGAB',
*       transactions: import/export
             ie_fiphr          LIKE sy-tcode VALUE 'CG31',
             ie_fisrc          LIKE sy-tcode VALUE 'CG32',
             ie_fisub          LIKE sy-tcode VALUE 'CG33',
             ie_fitem          LIKE sy-tcode VALUE 'CG34',
             ie_fiptr          LIKE sy-tcode VALUE 'CG35',
             ie_ibrep          LIKE sy-tcode VALUE 'CG36',
             ie_bb_sh          LIKE sy-tcode VALUE 'CG37',
             ie_bb_ch          LIKE sy-tcode VALUE 'CG38',
             ie_diinp          LIKE sy-tcode VALUE 'BMV0',
*       transaction codes for environment menu
*       changed to 2.2bpl3/2.5a: indirect jump to CGCL/CGCO/CGCV via
*        transaction CGCX to avoid authorization problems in productive
*        system (IMG is locked in productive systems, CGCX is open)
             srcmtn            LIKE sy-tcode VALUE 'CGCX',    " CGCL
             slsmtn            LIKE sy-tcode VALUE 'CGCX',    " CGCO
             usgmtn            LIKE sy-tcode VALUE 'CGCX',    " CGCV
*       transaction codes for report variants
*       variant_create  like sy-tcode value 'CG2A',
             variant_change    LIKE sy-tcode VALUE 'CG2B',
             variant_show      LIKE sy-tcode VALUE 'CG2C',
*       transaction codes for report layouts
             layout_change     LIKE sy-tcode VALUE 'CG42',
             layout_show       LIKE sy-tcode VALUE 'CG43',
             layout_change_old LIKE sy-tcode VALUE 'CG42OLD',
             layout_show_old   LIKE sy-tcode VALUE 'CG43OLD',
*       transaction codes for header page layouts
             hp_lay_change     LIKE sy-tcode VALUE 'CG4B',
             hp_lay_show       LIKE sy-tcode VALUE 'CG4C',
             hp_lay_change_old LIKE sy-tcode VALUE 'CG4BOLD',
             hp_lay_show_old   LIKE sy-tcode VALUE 'CG4COLD',
*       transaction codes for receive acknowledge layouts
             ra_lay_change     LIKE sy-tcode VALUE 'CG4D',
             ra_lay_show       LIKE sy-tcode VALUE 'CG4E',
             ra_lay_change_old LIKE sy-tcode VALUE 'CG4DOLD',
             ra_lay_show_old   LIKE sy-tcode VALUE 'CG4EOLD',
*       transaction codes for raw reports
             report_admin      LIKE sy-tcode VALUE 'CG50',
             report_inquiery   LIKE sy-tcode VALUE 'CG54',
             report_admin_wrkl LIKE sy-tcode VALUE 'CG55',
             report_admin_rrel LIKE sy-tcode VALUE 'CG56',
             report_admin_rver LIKE sy-tcode VALUE 'CG57',
             report_admin_rhis LIKE sy-tcode VALUE 'CG58',

             monitor_show      LIKE sy-tcode VALUE 'CG5Z',

             report_dist       LIKE sy-tcode VALUE 'CVD1',
             dang_goods_show   LIKE sy-tcode VALUE 'DGP3',
             dang_goods_change LIKE sy-tcode VALUE 'DGP2',

*       transactions codes for the formula object
             frml_change       LIKE sy-tcode VALUE 'FRML02',
             frml_show         LIKE sy-tcode VALUE 'FRML03',
             frml_infsys       LIKE sy-tcode VALUE 'FRML04',

* added because of transport errors M.S. 07.03.1998
             rawrep_change     LIKE sy-tcode VALUE '    ',
             rawrep_show       LIKE sy-tcode VALUE '    ',

*       occupational health
             oh_vu             LIKE sy-tcode VALUE 'EHSVU01',
             oh_vuex           LIKE sy-tcode VALUE 'EHSVU11',
           END OF ic_trcode.

CONSTANTS: true  TYPE boolean VALUE 'X',
           false TYPE boolean VALUE ' '.

************************************************************************
* structures / tables from DDIC
************************************************************************


************************************************************************
* types / constants
************************************************************************

CONSTANTS: lc_logical_filename_ftappl LIKE filename-fileintern
                                       VALUE 'EHS_FTAPPL'.
CONSTANTS: lc_logical_filename_ftfront LIKE filename-fileintern
                                       VALUE 'EHS_FTFRONT'.
CONSTANTS: lc_max_transfer_lines TYPE i VALUE 10000.

CONSTANTS: lc_fileformat_ascii LIKE rlgrap-filetype
                                       VALUE 'ASC'.

CONSTANTS: lc_fileformat_binary LIKE rlgrap-filetype
                                       VALUE 'BIN'.

************************************************************************
* internal tables
************************************************************************


************************************************************************
* fields / variables
************************************************************************
DATA lg_max_len TYPE i VALUE 2550.
