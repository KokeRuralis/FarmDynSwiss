************************************************************************
*
*   FarmDyn-project
*
*   Filetype:    GAMS program file
*   Responsible: W.Britz
*   Purpose:     Solve dummy model to release unused memoery.
*   See also:    util/kill_model.gms
*   Remarks:
************************************************************************
    solve XDUMMX using CNS;
