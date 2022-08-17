using System;
using System.Collections;

namespace Anomaly.ECS.Collections
{
	public class SparseArray
	{
		public struct Enumerator : IEnumerator<int>
		{
		    private SparseArray sparseArray;
		    private uint32 index;

		    public this(SparseArray sparseArray)
		    {
		        index = 0;
		        this.sparseArray = sparseArray;
		    }

		    private int Current
		    {
		        get { return sparseArray.dense[index-1]; }
		    }

		    private void MoveNext() mut
			{
		        index++;
		    }

		    Result<int> IEnumerator<int>.GetNext() mut
		    {
		        if (index >= sparseArray.count)
		            return .Err;

		        MoveNext();

		        return Current;
		    }
		}

		private int count;
		private readonly int[] dense;
		private readonly int[] sparse;

		public int Count => count;
		public readonly int[] Values => dense;

		public this(int capacity)
		{
			dense = new int[capacity];
			sparse = new int[capacity];
			count = 0;
		}

		public ~this()
		{
			delete dense;
			delete sparse;
		}

		public void Add(int value)
		{
			if (value >= 0 && value < dense.Count && !Contains(value))
			{
				dense[count] = value;
				sparse[value] = count;
				count++;
			}
		}

		public void Remove(int value)
		{
			if (Contains(value))
			{
				dense[sparse[value]] = dense[count - 1];
				sparse[dense[count - 1]] = sparse[value];
				count--;
			}
		}

		public bool Contains(int value)
		{
			if (value >= dense.Count || value < 0)
				return false;
			else
				return sparse[value] < count && dense[sparse[value]] == value;
		}

		public void Clear()
		{
			count = 0;
		}

		public Enumerator GetEnumerator()
		{
			return Enumerator(this);
		}
	}
}