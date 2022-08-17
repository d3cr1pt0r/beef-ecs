using System;
using System.Collections;

namespace Anomaly.ECS.Collections
{
	public class SparseSet<T> : System.IDisposable
	{
		typealias KeyValuePair=(int Key, T Value);
		typealias KeyRefValuePair=(int Key, T* ValueRef);

		public struct Enumerator : IEnumerator<KeyValuePair>, IRefEnumerator<KeyRefValuePair>
		{
		    private SparseSet<T> sparseSet;
		    private uint32 index;

		    public this(SparseSet<T> sparseSet)
		    {
		        index = 0;
		        this.sparseSet = sparseSet;
		    }

		    private KeyValuePair Current
		    {
		        get { return (sparseSet.dense[index-1], sparseSet.denseValues[index-1]); }
		    }

		    private KeyRefValuePair CurrentRef
		    {
		        get { return (sparseSet.dense[index-1], &sparseSet.denseValues[index-1]); }
		    }

		    private void MoveNext() mut {
				index++;
		    }

		    Result<KeyValuePair> IEnumerator<KeyValuePair>.GetNext() mut
		    {
		        if (index >= sparseSet.denseValues.Count)
		            return .Err;

		        MoveNext();

		        return Current;
		    }

		    Result<KeyRefValuePair> IRefEnumerator<KeyRefValuePair>.GetNextRef() mut
		    {
		        if (index >= sparseSet.denseValues.Count)
		            return .Err;

		        MoveNext();

		        return CurrentRef;
		    }
		}

		private int[] sparse;
		private SimpleList<int> dense;
		private SimpleList<T> denseValues;

		public readonly SimpleList<int> Indices => dense;
		public readonly SimpleList<T> Values => denseValues;

		public this(int capacity)
		{
			sparse = new int[capacity];
			for(int i=0; i<capacity; i++)
				sparse[i] = -1;

			dense = new SimpleList<int>(capacity);
			denseValues = new SimpleList<T>(capacity);
		}

		public ~this()
		{
			delete sparse;
			delete dense;
			delete denseValues;
		}

		public ref T this[int i]
		{
			get => ref denseValues[sparse[i]];
		}

		public ref T Add(int index, T value)
		{
			sparse[index] = denseValues.Count;
			denseValues.Add(value);
			dense.Add(index);

			return ref denseValues[sparse[index]];
		}

		public void Remove(int index)
		{
			if (!Contains(index))
				return;

			var denseIndex = sparse[index];
			var last = dense[dense.Count - 1];
			dense.Remove(denseIndex);
			denseValues.Remove(denseIndex);
			sparse[last] = sparse[index];
			sparse[index] = -1;
		}

		public void Clear()
		{
			for(int i=0; i<sparse.Count; i++)
				sparse[i] = -1;

			dense.Clear();
			denseValues.Clear();
		}

		public bool Contains(int index)
		{
			return index < sparse.Count && sparse[index] > -1;
		}

		public void Dispose()
		{
			denseValues.Dispose();
		}

		public Enumerator GetEnumerator()
		{
			return Enumerator(this);
		}
	}
}