using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Animation : MonoBehaviour
{
    public GameObject Obj;
    private Vector3 objPos;
    // Start is called before the first frame update
    void Start()
    {
        objPos = Obj.transform.position;
    }

    // Update is called once per frame
    void Update()
    {
        float t = Time.time * 8.0f;
        Vector3 pos = new Vector3(Mathf.Sin(t), Mathf.Cos(t*0.7f), Mathf.Sin(t*0.3f) * Mathf.Cos(t*0.45f));
        Quaternion q = Quaternion.Euler(pos * 90.0f);
        pos *= 0.4f;
        Obj.transform.SetPositionAndRotation(objPos + pos, q);
    }
}
