import { useQuery } from '@tanstack/react-query';
import { useRouter } from 'next/router';
import { postsApi } from '../lib/api';

export default function Posts() {
  const router = useRouter();
  const { data: posts, isLoading, error } = useQuery({
    queryKey: ['posts'],
    queryFn: () => postsApi.getAll(),
  });

  const handleLogout = () => {
    localStorage.removeItem('accessToken');
    localStorage.removeItem('user');
    router.push('/login');
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-900 to-slate-800 flex items-center justify-center">
        <div className="text-white text-xl">Loading posts...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-900 to-slate-800 flex items-center justify-center">
        <div className="text-red-400 text-xl">Error loading posts</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 to-slate-800">
      <div className="container mx-auto px-4 py-8">
        <div className="flex justify-between items-center mb-8">
          <h1 className="text-4xl font-bold text-white">Posts</h1>
          <button
            onClick={handleLogout}
            className="px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg font-semibold transition-colors"
          >
            Logout
          </button>
        </div>

        <div className="grid gap-6">
          {posts?.map((post: any) => (
            <div
              key={post.id}
              className="bg-white/10 backdrop-blur-lg rounded-lg p-6 border border-white/20"
            >
              <h2 className="text-2xl font-semibold text-white mb-2">
                {post.title}
              </h2>
              {post.content && (
                <p className="text-slate-300 mb-4">{post.content}</p>
              )}
              <div className="flex items-center justify-between text-sm text-slate-400">
                <span>By {post.author?.name || post.author?.email}</span>
                <span>
                  {post.published ? (
                    <span className="text-green-400">Published</span>
                  ) : (
                    <span className="text-yellow-400">Draft</span>
                  )}
                </span>
              </div>
            </div>
          ))}

          {posts?.length === 0 && (
            <div className="text-center text-slate-400 py-12">
              No posts found. Run the seed script to add sample data.
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
