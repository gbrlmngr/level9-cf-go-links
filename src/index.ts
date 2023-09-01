export interface Env {
	GO_LINKS: KVNamespace;
}

export default {
	async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
		try {
			const [, key] = new URL(request.url).pathname?.split('/') ?? [];
			const destination = await env.GO_LINKS.get(key?.toLowerCase());

			if (destination) {
				return Response.redirect(destination);
			} else {
				// Fallback to 404
				throw new Error();
			}
		} catch {
			return new Response('', { status: 404 });
		}
	},
};
