p_line(_,_,"start timers")
tmr_rst('rp')
tmr_rst('t')
tmr_rst('scrn')
TMR.heap.t, TMR.heap.f = 60000, node.heap
tmr_rst('heap')
