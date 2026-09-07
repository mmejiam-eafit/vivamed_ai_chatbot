def lum(h):
    h=h.lstrip('#'); c=[int(h[i:i+2],16)/255 for i in (0,2,4)]
    c=[(x/12.92 if x<=0.04045 else ((x+0.055)/1.055)**2.4) for x in c]
    return 0.2126*c[0]+0.7152*c[1]+0.0722*c[2]
def cr(a,b):
    la,lb=lum(a),lum(b); return round((max(la,lb)+0.05)/(min(la,lb)+0.05),2)
def chk(n,fg,bg,floor=4.5):
    r=cr(fg,bg); print(f"  {'OK ' if r>=floor else 'FAIL'} {r:6}  {n:44} {fg} on {bg}")
    return r>=floor
