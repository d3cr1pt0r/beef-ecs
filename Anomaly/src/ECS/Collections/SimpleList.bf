using System;
using System.Collections;

namespace Anomaly.ECS.Collections
{
	public extension SimpleList<T> where T : delete
	{
		public void Dispose()
		{
			for(int i=0; i<Count; i++)
				delete values[i];
		}
	}

	public class SimpleList<T> : System.IDisposable
	{
		public struct Enumerator : IEnumerator<T>, IRefEnumerator<T>
		{
		    private SimpleList<T> simpleList;
		    private uint32 index;

		    public this(SimpleList<T> simpleList)
		    {
		        index = 0;
		        this.simpleList = simpleList;
		    }

		    private T Current
		    {
		        get { return simpleList.values[index-1]; }
		    }

		    private ref T CurrentRef
		    {
		        get { return ref simpleList.values[index-1]; }
		    }

		    private void MoveNext() mut {
		        index++;
		    }

		    Result<T> IEnumerator<T>.GetNext() mut
		    {
		        if (index >= simpleList.end)
		            return .Err;

		        MoveNext();

		        return Current;
		    }

		    Result<T> IRefEnumerator<T>.GetNextRef() mut
		    {
		        if (index >= simpleList.end)
		            return .Err;

		        MoveNext();

		        return CurrentRef;
		    }
		}

		private T[] values;
		private int end = 0;

		public int Count => end;
		public int Reserved => values.Count;

		public this(int capacity = 0)
		{
			values = new T[capacity];
		}

		public ~this()
		{
			delete values;
		}

		public ref T this[int i]
		{
			get => ref values[i];
		}

		public void Add(T element)
		{
			System.Runtime.Assert(end < values.Count, "Maximum capacity reached!");

			values[end] = element;
			end++;
		}

		public void Remove(int index)
		{
			end--;
			if (index < end)
				values[index] = values[end];
		}

		public void Clear()
		{
			end = 0;
		}

		public void Dispose()
		{

		}
	}
}