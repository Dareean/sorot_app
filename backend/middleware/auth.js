import jwt from 'jsonwebtoken';

export const auth = (req, res, next) => {
  const h = req.headers.authorization || '';
  const token = h.startsWith('Bearer ') ? h.slice(7) : null;
  if (!token) return res.sendStatus(401);
  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    if (req.user.role !== 'admin') return res.sendStatus(403);
    next();
  } catch {
    return res.sendStatus(401);
  }
};

export const signAdmin = (id = 'admin') =>
  jwt.sign({ sub: id, role: 'admin' }, process.env.JWT_SECRET, { expiresIn: '12h' });
